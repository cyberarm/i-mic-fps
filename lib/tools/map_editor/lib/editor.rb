# frozen_string_literal: true
class IMICFPS
  class MapEditorTool
    class Editor < CyberarmEngine::GuiState
      attr_reader :map

      def setup
        # TODO: Move everything required for a playable game map
        #       in to a Scene or Scene3D container object
        #       and refactor Game to use it.
        Publisher.new
        @map = Map.new(map_parser: @options[:map_parser])
        @camera = PerspectiveCamera.new( position: Vector.new, aspect_ratio: window.aspect_ratio )
        @editor = IMICFPS::Editor.new( manifest: Manifest.new(package: "base", name: "editor") )
        @camera_controller = CameraController.new(camera: @camera, entity: @editor)
        @crosshair = Crosshair.new

        @map.setup
        @map.add_entity(@editor)
      end

      def draw
        super
        @map.render(@camera)
        @crosshair.draw
      end

      def update
        super
        Publisher.instance.publish(:tick, Gosu.milliseconds - window.delta_time)

        control_editor

        @map.update
        @camera_controller.update
      end

      def control_editor
        InputMapper.keys.each do |key, pressed|
          next unless pressed

          actions = InputMapper.actions(key)
          next unless actions

          actions.each do |action|
            @editor.send(action) if @editor.respond_to?(action)
          end
        end

        @editor.orientation.x = @camera.orientation.x
      end

      def button_down(id)
        if id == Gosu::KB_ESCAPE
          # TODO: Use Editor specific menu
          push_state(GamePauseMenu)

          return
        end

        InputMapper.keydown(id)
        Publisher.instance.publish(:button_down, nil, id)

        @camera_controller.button_down(id)

        @map.entities.each do |entity|
          entity.button_down(id) if defined?(entity.button_down)
        end
      end

      def button_up(id)
        InputMapper.keyup(id)
        Publisher.instance.publish(:button_up, nil, id)

        @map.entities.each do |entity|
          entity.button_up(id) if defined?(entity.button_up)
        end

        @camera_controller.button_up(id)
      end
    end
  end
end
