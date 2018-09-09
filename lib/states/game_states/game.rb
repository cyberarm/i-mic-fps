class IMICFPS
  class Game < GameState
    include OpenGL
    include GLU

    def setup
      @terrain = Terrain.new#(size: 170, height: 0)
      @draw_skydome = true
      @skydome = Skydome.new(scale: 0.08, backface_culling: false, auto_manage: false)

      25.times do
        Tree.new(x: rand(@terrain.width)-(@terrain.width/2.0), z: rand(@terrain.depth)-(@terrain.depth/2.0), terrain: @terrain)
      end

      @player = Player.new(x: 1, y: 0, z: -1, terrain: @terrain)
      @camera = Camera.new(x: 0, y: -2, z: 1)
      @camera.attach_to(@player)

      @crosshair_size = 10
      @crosshair_thickness = 3
      @crosshair_color = Gosu::Color.rgb(255,127,0)

      # @font = Gosu::Font.new(18, name: "DejaVu Sans")
      @text = MultiLineText.new("Pending...", x: 10, y: 10, z: 1, size: 18, font: "DejaVu Sans")

      Light.new(x: 3, y: -6, z: 6)
      Light.new(x: 0, y: 100, z: 0, diffuse: Color.new(1.0, 0.5, 0.1))
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

        LightManager.lights.each(&:draw)

        @camera.draw
        @skydome.draw if @skydome.renderable
        glEnable(GL_DEPTH_TEST)

        ObjectManager.objects.each do |object|
          object.draw if object.visible && object.renderable
        end
      end

      # Draw crosshair
      draw_rect($window.width/2-@crosshair_size, ($window.height/2-@crosshair_size)-@crosshair_thickness/2, @crosshair_size*2, @crosshair_thickness, @crosshair_color, 0, :default)
      draw_rect(($window.width/2)-@crosshair_thickness/2, $window.height/2-(@crosshair_size*2), @crosshair_thickness, @crosshair_size*2, @crosshair_color, 0, :default)

      @text.draw
    end

    def update
      @last_frame_time = Gosu.milliseconds
      begin
      string = <<-eos
OpenGL Vendor: #{glGetString(GL_VENDOR)}
OpenGL Renderer: #{glGetString(GL_RENDERER)}
OpenGL Version: #{glGetString(GL_VERSION)}
OpenGL Shader Language Version: #{glGetString(GL_SHADING_LANGUAGE_VERSION)}

Camera pitch: #{@camera.pitch.round(2)} Yaw: #{@camera.yaw.round(2)} Roll #{@camera.roll.round(2)}
Camera X:#{@camera.x.round(2)} Y:#{@camera.y.round(2)} Z:#{@camera.z.round(2)}
#{if @camera.game_object then "Actor X:#{@camera.game_object.x.round(2)} Y:#{@camera.game_object.y.round(2)} Z:#{@camera.game_object.z.round(2)}";end}
Field Of View: #{@camera.field_of_view}
Mouse Sesitivity: #{@camera.mouse_sensitivity}
Faces: #{$window.number_of_faces}
Last Frame: #{delta_time*1000.0}ms (#{Gosu.fps} fps)

Draw Skydome: #{@draw_skydome}
Debug mode: <c=992200>#{$debug}</c>
eos
      rescue ArgumentError
        string = <<-eos
Unable to call glGetString!

Camera pitch: #{@camera.pitch.round(2)} Yaw: #{@camera.yaw.round(2)} Roll #{@camera.roll.round(2)}
Camera X:#{@camera.x.round(2)} Y:#{@camera.y.round(2)} Z:#{@camera.z.round(2)}
#{if @camera.game_object then "Actor X:#{@camera.game_object.x.round(2)} Y:#{@camera.game_object.y.round(2)} Z:#{@camera.game_object.z.round(2)}";end}
Field Of View: #{@camera.field_of_view}
Mouse Sesitivity: #{@camera.mouse_sensitivity}
Faces: #{@number_of_faces}
Last Frame: #{delta_time*1000.0}ms (#{Gosu.fps} fps)

Draw Skydome: #{@draw_skydome}
Debug mode: <c=992200>#{$debug}</c>
eos
      end
      @text.text = string

      # ObjectManager.objects.each do |object|
      #   ObjectManager.objects.each do |b|
      #     next if b == object
      #     if object.intersect(object, b)
      #       # puts "#{object} is intersecting #{b}"
      #     end
      #   end
      #   object.update
      # end
      ObjectManager.objects.each(&:update)

      @skydome.update if @skydome.renderable

      @camera.update

      $window.close if $window.button_down?(Gosu::KbEscape)
      $window.number_of_faces = 0
      @delta_time = Gosu.milliseconds
    end

    def button_up(id)
      ObjectManager.objects.each do |object|
        object.button_up(id) if defined?(object.button_up)
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