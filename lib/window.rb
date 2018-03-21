class IMICFPS
  class Window < Gosu::Window
    include OpenGL
    include GLU
    # include GLUT

    attr_accessor :number_of_faces, :needs_cursor

    def initialize(window_width = 1280, window_height = 800, fullscreen = false)
      if ARGV.join.include?("--native")
        super(Gosu.screen_width, Gosu.screen_height, true)
      else
        super(window_width, window_height, fullscreen)
      end
      $window = self
      @needs_cursor = false

      @delta_time = Gosu.milliseconds
      @number_of_faces = 0
      @draw_skydome = true
      @skydome = Model.new(type: :obj, file_path: "objects/skydome.obj", x: 0, y: 0,z: 0, scale: 1, backface_culling: false, auto_manage: false)
      @actor = Model.new(type: :obj, file_path: "objects/biped.obj", x: 0, y: 0, z: -2)
      Model.new(type: :obj, file_path: "objects/tree.obj", x: 0, y: 0, z: -10)
      # Model.new(type: :obj, file_path: "objects/tree.obj", z: -5)
      # Model.new(type: :obj, file_path: "objects/tree.obj", x: -2, z: -6)
      # Model.new(type: :obj, file_path: "objects/sponza.obj", scale: 1, y: -0.2)
      @terrain = Terrain.new(size: 100)

      @camera = Camera.new(x: 0, y: -2, z: 1)
      @camera.bind_model(@actor)

      @crosshair_size = 10
      @crosshair_thickness = 3
      @crosshair_color = Gosu::Color.rgb(255,127,0)

      @font = Gosu::Font.new(18, name: "DejaVu Sans")
      @text = "Hello There"

      Light.new(x: 3, y: -6, z: 6)
      Light.new(x: 0, y: -100, z: 0, diffuse: Color.new(1.0, 0.5, 0.1))
    end

    def draw
      e = glGetError()
      if e != GL_NO_ERROR
        $stderr.puts "OpenGL error in: #{gluErrorString(e)} (#{e})\n"
        exit
      end

      gl do
        glClearColor(0,0.2,0.5,1) # skyish blue
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) # clear the screen and the depth buffer

        LightManager.lights.each do |light|
          light.draw
        end
        @camera.draw
        @skydome.draw if @skydome.renderable
        ObjectManager.objects.each do |object|
          object.draw if object.visible && object.renderable
        end
        @terrain.draw
      end

      # Draw crosshair
      draw_rect(width/2-@crosshair_size, (height/2-@crosshair_size)-@crosshair_thickness/2, @crosshair_size*2, @crosshair_thickness, @crosshair_color, 0, :default)
      draw_rect((width/2)-@crosshair_thickness/2, height/2-(@crosshair_size*2), @crosshair_thickness, @crosshair_size*2, @crosshair_color, 0, :default)

      @text.split("~").each_with_index do |bit, i|
        @font.draw(bit.strip, 10, @font.height*i, Float::INFINITY)
      end
    end

    def update
      @last_frame_time = Gosu.milliseconds
      @text = "OpenGL Vendor: #{glGetString(GL_VENDOR)}~
      OpenGL Renderer: #{glGetString(GL_RENDERER)} ~
      OpenGL Version: #{glGetString(GL_VERSION)}~
      OpenGL Shader Language Version: #{glGetString(GL_SHADING_LANGUAGE_VERSION)}~
      ~
      Vertical Angle: #{@camera.vertical_angle.round(2)} Horizontal Angle: #{@camera.horizontal_angle.round(2)} ~
      Camera X:#{@camera.x.round(2)} Y:#{@camera.y.round(2)} Z:#{@camera.z.round(2)} ~
      #{if @camera.bound_model then "Actor X:#{@camera.bound_model.x.round(2)} Y:#{@camera.bound_model.y.round(2)} Z:#{@camera.bound_model.z.round(2)}";end} ~
      Field Of View: #{@camera.field_of_view} ~
      Mouse Sesitivity: #{@camera.mouse_sensitivity} ~
      Faces: #{@number_of_faces} ~
      Last Frame: #{delta_time}ms (#{Gosu.fps} fps)~
      ~
      Draw Skydome: #{@draw_skydome}~
      Debug mode: <c=992200>#{$debug}</b>~"

      ObjectManager.objects.each do |object|
        object.update
      end

      @camera.update

      $window.close if $window.button_down?(Gosu::KbEscape)
      @number_of_faces = 0
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
        @skydome.renderable = @draw_skydome
      when Gosu::KbBacktick
        $debug = !$debug
      end
    end

    def needs_cursor?
      @needs_cursor
     end

    def lose_focus
      puts 'Bye'
    end

    def delta_time
      Gosu.milliseconds-@delta_time
    end
  end
end
