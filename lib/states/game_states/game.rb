class IMICFPS
  class Game < GameState

    attr_reader :map
    def setup
      @map = Map.new(map_parser: @options[:map_parser])
      @map.setup

      @player = @map.find_entity_by(name: "character")
      @camera = Camera.new(position: @player.position.clone)
      @camera.attach_to(@player)
      @director = Networking::Director.new(mode: :memory, hostname: "i-mic.rubyclan.org", port: 56789, interface: { server: Networking::MemoryServer, connection: Networking::MemoryConnection }, state: self)

      @crosshair = Crosshair.new
      @hud = HUD.new(@player)

      @text = Text.new("Pending...", x: 10, y: 22, z: 1, size: 18, font: "DejaVu Sans", shadow_color: Gosu::Color::BLACK)

      if ARGV.join.include?("--playdemo")
        @demo = Demo.new(camera: @camera, player: @player, demo: "./demo.dat", mode: :play) if File.exist?("./demo.dat")

      elsif ARGV.join.include?("--savedemo")
        @demo = Demo.new(camera: @camera, player: @player, demo: "./demo.dat", mode: :record)
      end
    end

    def draw
      @map.render(@camera)

      @crosshair.draw
      @hud.draw
      @text.draw
    end

    def update
      update_text

      Publisher.instance.publish(:tick, Gosu.milliseconds - window.delta_time)

      @map.update

      control_player
      @hud.update

      @camera.update
      @director.tick(window.dt)

      if window.config.get(:debug_options, :stats)
        @text.text = update_text
      else
        @text.text = ""
      end

      @demo.update if @demo
    end

    def update_text
      string = <<-eos
OpenGL Vendor: #{glGetString(GL_VENDOR)}
OpenGL Renderer: #{glGetString(GL_RENDERER)}
OpenGL Version: #{glGetString(GL_VERSION)}
OpenGL Shader Language Version: #{glGetString(GL_SHADING_LANGUAGE_VERSION)}

Camera Pitch: #{@camera.orientation.x.round(2)} Yaw: #{@camera.orientation.y.round(2)} Roll #{@camera.orientation.z.round(2)}
Camera X: #{@camera.position.x.round(2)} Y: #{@camera.position.y.round(2)} Z: #{@camera.position.z.round(2)}
Camera Field Of View: #{@camera.field_of_view}
Camera Mouse Sesitivity: #{@camera.mouse_sensitivity}

#{if @camera.entity then "Actor X: #{@camera.entity.position.x.round(2)} Y: #{@camera.entity.position.y.round(2)} Z: #{@camera.entity.position.z.round(2)}";end}
eos
    end

    def control_player
      InputMapper.keys.each do |key, pressed|
        next unless pressed

        action = InputMapper.action(key)
        next unless action

        @player.send(action) if @player.respond_to?(action)
      end
    end

    def button_down(id)
      if id == Gosu::KB_ESCAPE
        push_state(GamePauseMenu)

        return
      end
      @demo.button_down(id) if @demo

      InputMapper.keydown(id)
      Publisher.instance.publish(:button_down, nil, id)

      @map.entities.each do |entity|
        entity.button_down(id) if defined?(entity.button_down)
      end
    end

    def button_up(id)
      @demo.button_up(id) if @demo

      InputMapper.keyup(id)
      Publisher.instance.publish(:button_up, nil, id)

      @map.entities.each do |entity|
        entity.button_up(id) if defined?(entity.button_up)
      end

      @camera.button_up(id)
    end

    def needs_cursor?
      @needs_cursor
    end

    def lose_focus
      puts 'Bye'
    end
  end
end
