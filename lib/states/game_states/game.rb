class IMICFPS
  class Game < GameState

    attr_reader :map
    def setup
      @map = Map.new(map_loader: @options[:map_loader])
      @map.setup

      @player = @map.find_entity_by(name: "biped")
      @camera = Camera.new(position: @player.position.clone)
      @camera.attach_to(@player)

      @crosshair_size = 10
      @crosshair_thickness = 3
      @crosshair_color = Gosu::Color.rgb(255,127,0)

      @text = Text.new("Pending...", x: 10, y: 10, z: 1, size: 18, font: "DejaVu Sans", shadow_color: Gosu::Color::BLACK)

      if ARGV.join.include?("--playdemo")
        @demo_data = File.exist?("./demo.dat") ? File.read("./demo.dat").lines : ""
        @demo_index= 0
        @demo_tick = 0

      elsif ARGV.join.include?("--savedemo")
        @demo_file = File.open("./demo.dat", "w")
        @demo_index= 0
        @demo_changed = false

        @demo_last_pitch = @camera.orientation.z
        @demo_last_yaw   = @camera.orientation.y

        at_exit { @demo_file.close }
      end
    end

    def draw
      @map.render(@camera)
      # Draw crosshair
      draw_rect(window.width/2-@crosshair_size, (window.height/2-@crosshair_size)-@crosshair_thickness/2, @crosshair_size*2, @crosshair_thickness, @crosshair_color, 0, :default)
      draw_rect((window.width/2)-@crosshair_thickness/2, window.height/2-(@crosshair_size*2), @crosshair_thickness, @crosshair_size*2, @crosshair_color, 0, :default)

      @text.draw
    end

    def update
      update_text

      Publisher.instance.publish(:tick, Gosu.milliseconds - window.delta_time)

      @map.update

      control_player

      @camera.update

      if $debug.get(:stats)
        @text.text = update_text
      elsif $debug.get(:fps)
        @text.text = "FPS: #{Gosu.fps}"
      else
        @text.text = ""
      end

      if ARGV.join.include?("--playdemo")
        if @demo_data[@demo_index]&.start_with?("tick")
          if @demo_tick == @demo_data[@demo_index].split(" ").last.to_i
            @demo_index+=1

            until(@demo_data[@demo_index]&.start_with?("tick"))
              break unless @demo_data[@demo_index]

              data = @demo_data[@demo_index].split(" ")
              if data.first == "up"
                input = InputMapper.get(data.last.to_sym)
                key = input.is_a?(Array) ? input.first : input
                self.button_up(key)

              elsif data.first == "down"
                input = InputMapper.get(data.last.to_sym)
                key = input.is_a?(Array) ? input.first : input
                self.button_down(key)

              elsif data.first == "mouse"
                @camera.orientation.z = data[1].to_f
                @player.orientation.y = (data[2].to_f * -1) - 180
              else
                # hmm
              end

              @demo_index += 1
            end
          end
        end
      end

      if ARGV.join.include?("--savedemo")
        if @camera.orientation.z != @demo_last_pitch || @camera.orientation.y != @demo_last_yaw
          unless @demo_last_written_index == @demo_index
            @demo_last_written_index = @demo_index
            @demo_file.puts("tick #{@demo_index}")
          end

          @demo_file.puts("mouse #{@camera.orientation.z} #{@camera.orientation.y}")
          @demo_last_pitch = @camera.orientation.z
          @demo_last_yaw   = @camera.orientation.y
        end

        @demo_changed = false
        @demo_index  += 1
      end

      @demo_tick += 1 if @demo_tick

      window.close if window.button_down?(Gosu::KbEscape)
      window.number_of_vertices = 0
    end

    def update_text
      string = <<-eos
OpenGL Vendor: #{glGetString(GL_VENDOR)}
OpenGL Renderer: #{glGetString(GL_RENDERER)}
OpenGL Version: #{glGetString(GL_VERSION)}
OpenGL Shader Language Version: #{glGetString(GL_SHADING_LANGUAGE_VERSION)}

Camera pitch: #{@camera.orientation.z.round(2)} Yaw: #{@camera.orientation.y.round(2)} Roll #{@camera.orientation.x.round(2)}
Camera X:#{@camera.position.x.round(2)} Y:#{@camera.position.y.round(2)} Z:#{@camera.position.z.round(2)}
#{if @camera.entity then "Actor X:#{@camera.entity.position.x.round(2)} Y:#{@camera.entity.position.y.round(2)} Z:#{@camera.entity.position.z.round(2)}";end}
Field Of View: #{@camera.field_of_view}
Mouse Sesitivity: #{@camera.mouse_sensitivity}
Last Frame: #{Gosu.milliseconds - window.delta_time}ms (#{Gosu.fps} fps)

Vertices: #{formatted_number(window.number_of_vertices)}
Faces: #{formatted_number(window.number_of_vertices/3)}
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
      if ARGV.join.include?("--savedemo")
        unless @demo_last_written_index == @demo_index
          @demo_last_written_index = @demo_index
          @demo_file.puts("tick #{@demo_index}")
        end
        @demo_file.puts("down #{InputMapper.action(id)}")
        @demo_changed = true
      end
      InputMapper.keydown(id)
      Publisher.instance.publish(:button_down, nil, id)

      @map.entities.each do |entity|
        entity.button_down(id) if defined?(entity.button_down)
      end
    end

    def button_up(id)
      if ARGV.join.include?("--savedemo")
        unless @demo_last_written_index == @demo_index
          @demo_last_written_index = @demo_index
          @demo_file.puts("tick #{@demo_index}")
        end
        @demo_file.puts("up #{InputMapper.action(id)}")
        @demo_changed = true
      end
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
