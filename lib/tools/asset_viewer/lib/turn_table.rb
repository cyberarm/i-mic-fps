class IMICFPS
  class AssetViewerTool
    class TurnTable < CyberarmEngine::GuiState
      include LightManager

      attr_reader :map
      def setup
        window.needs_cursor = false
        @manifest = @options[:manifest]

        if window.config.get(:debug_options, :use_shaders) && !Shader.available?("default")
          Shader.new(
            name: "default",
            includes_dir: "shaders/include",
            vertex: "shaders/vertex/default.glsl",
            fragment: "shaders/fragment/default.glsl"
          )
        end

        @map = ProtoMap.new
        Publisher.new

        @entity = Entity.new(manifest: @manifest, auto_manage: false)
        @entity.bind_model
        @map.add_entity(@entity)
        @map.entities.each { |e| e.backface_culling = false }
        @crosshair = Crosshair.new(color: Gosu::Color.rgba(100, 200, 255, 100))

        @lights = []
        @light = Light.new(id: available_light, position: Vector.new, diffuse: Vector.new(1, 1, 1, 1))
        @lights << @light

        @camera = Camera.new(position: Vector.new(0, 1.5, 5), orientation: Vector.forward)
        @renderer = Renderer.new

        label @manifest.name, text_size: 50
        label @manifest.model
        @camera_position    = label ""
        @camera_orientation = label ""

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
          0, window.height, color_bottom,
        )

        Gosu.gl do
          @renderer.draw(@camera, [@light], @map.entities)
        end

        @crosshair.draw

        super
      end

      def update
        super

        @camera.update
        @light.position = @camera.position.clone
        @light.position.y += 1.5
        @camera_position.value = "Camera Position: X #{@camera.position.x.round(2)}, Y #{@camera.position.y.round(2)}, Z #{@camera.position.z.round(2)}"
        @camera_orientation.value = "Camera Orientation: X #{@camera.orientation.x.round(2)}, Y #{@camera.orientation.y.round(2)}, Z #{@camera.orientation.z.round(2)}\nEntities: #{@map.entities.count}"

        @map.entities.each(&:update)
      end

      def button_down(id)
        super

        InputMapper.keydown(id)
      end

      def button_up(id)
        super

        InputMapper.keyup(id)
        @camera.button_up(id)
      end
    end

    # Stub for enabling scripted models to load properly
    class ProtoMap
      include EntityManager

      attr_reader :entities
      def initialize
        @entities = []
      end
    end
  end
end