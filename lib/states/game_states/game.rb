# frozen_string_literal: true

class IMICFPS
  class Game < GameState
    attr_reader :map

    def setup
      window.director.load_map(map_parser: @options[:map_parser])

      @player = window.director.map.find_entity_by(name: "character")
      @camera = PerspectiveCamera.new(position: @player.position.clone, aspect_ratio: window.aspect_ratio)
      @camera_controller = CameraController.new(mode: :fpv, camera: @camera, entity: @player)

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
      window.director.map.render(@camera)

      @hud.draw if window.config.get(:options, :hud)
    end

    def update
      control_player
      @hud.update
      @camera_controller.update

      # @connection.update
      window.director.tick(window.dt)

      @demo&.update
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
      @demo&.button_down(id)
      @camera_controller.button_down(id)

      InputMapper.keydown(id)
      Publisher.instance.publish(:button_down, nil, id)

      window.director.map.entities.each do |entity|
        entity.button_down(id) if defined?(entity.button_down)
      end
    end

    def button_up(id)
      @demo&.button_up(id)
      @camera_controller.button_up(id)

      InputMapper.keyup(id)
      Publisher.instance.publish(:button_up, nil, id)

      window.director.map.entities.each do |entity|
        entity.button_up(id) if defined?(entity.button_up)
      end
    end
  end
end
