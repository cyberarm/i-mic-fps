class IMICFPS
  class Game < GameState
    include OpenGL
    include GLU

    def setup
      @collision_manager = CollisionManager.new(game_state: self)
      @renderer = Renderer.new(game_state: self)
      add_entity(Terrain.new)
      @draw_skydome = true
      @skydome = Skydome.new(scale: 0.08, backface_culling: false)
      add_entity(@skydome)

      25.times do
        add_entity(Tree.new)
      end

      add_entity(TestObject.new(z: 10))

      @player = Player.new(x: 1, y: 0, z: -1)
      add_entity(@player)
      @camera = Camera.new(x: 0, y: -2, z: 1)
      @camera.attach_to(@player)

      @crosshair_size = 10
      @crosshair_thickness = 3
      @crosshair_color = Gosu::Color.rgb(255,127,0)

      # @font = Gosu::Font.new(18, name: "DejaVu Sans")
      @text = Text.new("Pending...", x: 10, y: 10, z: 1, size: 18, font: "DejaVu Sans")

      Light.new(x: 3, y: -6, z: 6, game_state: self)
      Light.new(x: 0, y: 100, z: 0, diffuse: Color.new(1.0, 0.5, 0.1), game_state: self)

      if ARGV.join.include?("--playdemo")
        @demo_data = File.exist?("./demo.dat") ? File.read("./demo.dat").lines : ""
        @demo_index= 0
        @demo_tick = 0

      elsif ARGV.join.include?("--savedemo")
        @demo_file = File.open("./demo.dat", "w")
        @demo_index= 0
        @demo_changed = false

        @demo_last_pitch = @camera.pitch
        @demo_last_yaw   = @camera.yaw

        at_exit { @demo_file.close }
      end
    end

    def glError?
      e = glGetError()
      if e != GL_NO_ERROR
        $stderr.puts "OpenGL error in: #{gluErrorString(e)} (#{e})\n"
        exit
      end
    end

    def draw
      glError?

      gl do
        glError?
        glClearColor(0,0.2,0.5,1) # skyish blue
        glError?
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) # clear the screen and the depth buffer
        glError?

        @lights.each(&:draw)

        @camera.draw
        @renderer.opengl_renderer.draw_object(@skydome) if @skydome.renderable
        glEnable(GL_DEPTH_TEST)

        @renderer.draw
      end

      # Draw crosshair
      draw_rect(window.width/2-@crosshair_size, (window.height/2-@crosshair_size)-@crosshair_thickness/2, @crosshair_size*2, @crosshair_thickness, @crosshair_color, 0, :default)
      draw_rect((window.width/2)-@crosshair_thickness/2, window.height/2-(@crosshair_size*2), @crosshair_thickness, @crosshair_size*2, @crosshair_color, 0, :default)

      @text.draw
    end

    def update
      @last_frame_time = Gosu.milliseconds
      update_text

      @collision_manager.update
      @entities.each(&:update)

      @skydome.update if @skydome.renderable

      @camera.update

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
                @camera.pitch = data[1].to_f
                @player.rotation.y = (data[2].to_f * -1) - 180
              else
                # hmm
              end

              @demo_index += 1
            end
          end
        end
      end

      if ARGV.join.include?("--savedemo")
        if @camera.pitch != @demo_last_pitch || @camera.yaw != @demo_last_yaw
          unless @demo_last_written_index == @demo_index
            @demo_last_written_index = @demo_index
            @demo_file.puts("tick #{@demo_index}")
          end

          @demo_file.puts("mouse #{@camera.pitch} #{@camera.yaw}")
          @demo_last_pitch = @camera.pitch
          @demo_last_yaw   = @camera.yaw
        end

        @demo_changed = false
        @demo_index  += 1
      end

      @demo_tick += 1 if @demo_tick

      window.close if window.button_down?(Gosu::KbEscape)
      window.number_of_vertices = 0
      @delta_time = Gosu.milliseconds
    end

    def update_text
      begin
      string = <<-eos
OpenGL Vendor: #{glGetString(GL_VENDOR)}
OpenGL Renderer: #{glGetString(GL_RENDERER)}
OpenGL Version: #{glGetString(GL_VERSION)}
OpenGL Shader Language Version: #{glGetString(GL_SHADING_LANGUAGE_VERSION)}

Camera pitch: #{@camera.pitch.round(2)} Yaw: #{@camera.yaw.round(2)} Roll #{@camera.roll.round(2)}
Camera X:#{@camera.position.x.round(2)} Y:#{@camera.position.y.round(2)} Z:#{@camera.position.z.round(2)}
#{if @camera.entity then "Actor X:#{@camera.entity.position.x.round(2)} Y:#{@camera.entity.position.y.round(2)} Z:#{@camera.entity.position.z.round(2)}";end}
Field Of View: #{@camera.field_of_view}
Mouse Sesitivity: #{@camera.mouse_sensitivity}
Last Frame: #{delta_time*1000.0}ms (#{Gosu.fps} fps)

Vertices: #{formatted_number(window.number_of_vertices)}
Faces: #{formatted_number(window.number_of_vertices/3)}

Draw Skydome: #{@draw_skydome}
Debug mode: <c=992200>#{$debug}</c>
eos
      rescue ArgumentError
        string = <<-eos
Unable to call glGetString!

Camera pitch: #{@camera.pitch.round(2)} Yaw: #{@camera.yaw.round(2)} Roll #{@camera.roll.round(2)}
Camera X:#{@camera.x.round(2)} Y:#{@camera.y.round(2)} Z:#{@camera.z.round(2)}
#{if @camera.entity then "Actor X:#{@camera.entity.x.round(2)} Y:#{@camera.entity.y.round(2)} Z:#{@camera.entity.z.round(2)}";end}
Field Of View: #{@camera.field_of_view}
Mouse Sesitivity: #{@camera.mouse_sensitivity}
Last Frame: #{delta_time*1000.0}ms (#{Gosu.fps} fps)

Vertices: #{formatted_number(window.number_of_vertices)}
Faces: #{formatted_number(window.number_of_vertices/3)}

Draw Skydome: #{@draw_skydome}
Debug mode: <c=992200>#{$debug}</c>
eos
      end
      if $debug
        @text.text = string
      else
        @text.text = "FPS: #{Gosu.fps}"
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

      @entities.each do |entity|
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

      @entities.each do |entity|
        entity.button_up(id) if defined?(entity.button_up)
      end

      @camera.button_up(id)

      case id
      when Gosu::KbZ
        @draw_skydome = !@draw_skydome
      when Gosu::KbBacktick
        $debug = !$debug
      end
      @skydome.renderable = @draw_skydome
    end

    def needs_cursor?
      @needs_cursor
    end

    def lose_focus
      puts 'Bye'
    end
  end
end
