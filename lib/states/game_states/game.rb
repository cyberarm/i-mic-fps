class IMICFPS
  class Game < GameState

    attr_reader :map
    def setup
      @map = Map.new(map_parser: @options[:map_parser])
      @map.setup

      @player = @map.find_entity_by(name: "character")
      @camera = PerspectiveCamera.new( position: @player.position.clone, aspect_ratio: window.aspect_ratio )
      @camera_controller = CameraController.new(mode: :fpv, camera: @camera, entity: @player)
      # @director = Networking::Director.new
      # @director.load_map(map_parser: @options[:map_parser])

      # @connection = Networking::Connection.new(address: "localhost", port: Networking::DEFAULT_SERVER_PORT)
      # @connection.connect

      @hud = HUD.new(@player)

      if ARGV.join.include?("--playdemo")
        @demo = Demo.new(camera: @camera, player: @player, demo: "./demo.dat", mode: :play) if File.exist?("./demo.dat")

      elsif ARGV.join.include?("--savedemo")
        @demo = Demo.new(camera: @camera, player: @player, demo: "./demo.dat", mode: :record)
      end
    end

    def draw
      @map.render(@camera)

      @hud.draw
    end

    def update
      update_text

      control_player
      @hud.update
      @camera_controller.update

      # @connection.update
      # @director.tick(window.dt)
      @map.update

      @demo.update if @demo
    end

    def update_text
      string = <<-eos
OpenGL Vendor: #{glGetString(GL_VENDOR)}
OpenGL Renderer: #{glGetString(GL_RENDERER)}
OpenGL Version: #{glGetString(GL_VERSION)}
OpenGL Shader Language Version: #{glGetString(GL_SHADING_LANGUAGE_VERSION)}
eos
    end

    def control_player
      InputMapper.keys.each do |key, pressed|
        next unless pressed

        actions = InputMapper.actions(key)
        next unless actions

        actions.each do |action|
          @player.send(action) if @player.respond_to?(action)
        end
      end
    end

    def button_down(id)
      if id == Gosu::KB_ESCAPE
        push_state(GamePauseMenu)

        return
      end
      @demo.button_down(id) if @demo
      @camera_controller.button_down(id)

      InputMapper.keydown(id)
      Publisher.instance.publish(:button_down, nil, id)

      @map.entities.each do |entity|
        entity.button_down(id) if defined?(entity.button_down)
      end
    end

    def button_up(id)
      @demo.button_up(id) if @demo
      @camera_controller.button_up(id)

      InputMapper.keyup(id)
      Publisher.instance.publish(:button_up, nil, id)

      @map.entities.each do |entity|
        entity.button_up(id) if defined?(entity.button_up)
      end
    end
  end
end
