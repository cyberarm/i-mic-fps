class IMICFPS
  class MapEditorTool
    class Editor < CyberarmEngine::GuiState

      attr_reader :map
      def setup
        # TODO: Move everything required for a playable game map
        #       in to a Scene or Scene3D container object
        #       and refactor Game to use it.
        Publisher.new
        @map = Map.new( map_parser: @options[:map_parser] )
        @camera = Camera.new( position: Vector.new )
        @crosshair = Crosshair.new

        @map.setup
      end

      def draw
        super
        @map.render(@camera)
        @crosshair.draw
      end

      def update
        super
        Publisher.instance.publish(:tick, Gosu.milliseconds - window.delta_time)
        @map.update
        @camera.update
      end

      def button_down(id)
        if id == Gosu::KB_ESCAPE
          # TODO: Use Editor specific menu
          push_state(GamePauseMenu)

          return
        end

        InputMapper.keydown(id)
        Publisher.instance.publish(:button_down, nil, id)

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

        @camera.button_up(id)
      end
    end
  end
end
