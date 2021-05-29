# frozen_string_literal: true

class IMICFPS
  class AssetViewerTool
    class TurnTable < CyberarmEngine::GuiState
      attr_reader :map

      def setup
        window.needs_cursor = false
        @manifest = @options[:manifest]

        window.director.load_map(map_parser: MapParser.new(map_file: "#{GAME_ROOT_PATH}/maps/model_viewer.json"))
        @map = window.director.map

        @entity = Entity.new(manifest: @manifest)
        @entity.bind_model
        @map.add_entity(@entity)
        @map.entities.each { |e| e.backface_culling = false }
        @crosshair = Crosshair.new(color: Gosu::Color.rgba(100, 200, 255, 100))

        @map.add_light @light = Light.new(type: Light::DIRECTIONAL, id: @map.available_light, position: Vector.new, diffuse: Vector.new(1, 1, 1, 1))

        @camera = PerspectiveCamera.new(aspect_ratio: window.aspect_ratio, position: Vector.new(0, 1.5, 5), orientation: Vector.forward)
        @camera_controller = CameraController.new(camera: @camera, entity: nil, mode: :fpv)

        label @manifest.name, text_size: 50, text_border: true, text_border_color: Gosu::Color::BLACK
        label @manifest.model, text_border: true, text_border_color: Gosu::Color::BLACK
        @camera_position    = label "", text_border: true, text_border_color: Gosu::Color::BLACK
        @camera_orientation = label "", text_border: true, text_border_color: Gosu::Color::BLACK

        button "Back" do
          pop_state
        end
      end

      def draw
        color_top = Gosu::Color::GRAY
        color_bottom = Gosu::Color::BLACK

        Gosu.draw_quad(
          0, 0, color_top,
          window.width, 0, color_top,
          window.width, window.height, color_bottom,
          0, window.height, color_bottom
        )

        Gosu.gl do
          window.renderer.draw(@camera, @map.lights, @map.entities)
        end

        @crosshair.draw

        super
      end

      def update
        super

        @light.position = @camera.position.clone
        @light.position.y += 1.5
        @camera_position.value = "Camera Position: X #{@camera.position.x.round(2)}, Y #{@camera.position.y.round(2)}, Z #{@camera.position.z.round(2)}"
        @camera_orientation.value = "Camera Orientation: X #{@camera.orientation.x.round(2)}, Y #{@camera.orientation.y.round(2)}, Z #{@camera.orientation.z.round(2)}\nEntities: #{@map.entities.count}"

        @camera_controller.free_move
        @camera_controller.update

        # @map.entities.each(&:update)
      end

      def button_down(id)
        super

        InputMapper.keydown(id)
        @camera_controller.button_down(id)
      end

      def button_up(id)
        super

        InputMapper.keyup(id)
        @camera_controller.button_up(id)
      end
    end
  end
end
