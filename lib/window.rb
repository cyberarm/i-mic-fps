class IMICFPS
  class Window < Gosu::Window
    include OpenGL
    include GLU
    # include GLUT
    Point = Struct.new(:x, :y)

    attr_accessor :number_of_faces

    def initialize(window_width = 1280, window_height = 800, fullscreen = false)
      super(window_width, window_height, fullscreen)
      # super(Gosu.screen_width, Gosu.screen_height, true)
      $window = self
      @delta_time = Gosu.milliseconds
      @number_of_faces = 0
      @draw_skydome = true
      @skydome = Wavefront::Model.new("objects/skydome.obj")
      @model = Wavefront::Model.new("objects/biped.obj")
      @scene = Wavefront::Model.new("objects/cube.obj")
      @tree = Wavefront::Model.new("objects/tree.obj")
      # @mega_model = Wavefront::Model.new("objects/sponza.obj")

      @camera = Wavefront::Model::Vertex.new(0,-1,0)
      @camera_target = Wavefront::Model::Vertex.new(0,-1,0)
      @speed = 0.05
      @angle_y = 0.0 # |
      @angle_x = 0.0 # _
      @mouse = Point.new(Gosu.screen_width/2, Gosu.screen_height/2)
      self.mouse_x, self.mouse_y = Gosu.screen_width/2, Gosu.screen_height/2
      @mouse_sesitivity = 5.0

      @font = Gosu::Font.new(18, name: "DejaVu Sans")
      @text = "Hello There"
      @last_frame_time = 0
      @tick = 0
      @c1, @c2, @c3 = rand(0.0..1.0), rand(0.0..1.0), rand(0.0..1.0)

      @ambient_light = [0.5, 0.5, 0.5, 1]
      @diffuse_light = [1, 0.5, 0, 1]
      @specular_light = [0.2, 0.2, 0.2, 1]
      @light_postion = [1, 1, 1, 0]

      @camera_light = Light.new(0,0,0)
      @camera_light.ambient = @ambient_light
      @camera_light.diffuse = @diffuse_light
      @camera_light.specular = @specular_light
      @camera_light.specular = @specular_light
    end

    def draw
      e = glGetError()
      if e != GL_NO_ERROR
        $stderr.puts "OpenGL error in: #{gluErrorString(e)} (#{e})\n"
        exit
      end
      render
    end

    def render
      gl do
        glClearColor(0,0.2,0.5,1) # skyish blue
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) # clear the screen and the depth buffer

        #glMatrixMode(matrix) indicates that following [matrix] is going to get used
        glMatrixMode(GL_PROJECTION) # The projection matrix is responsible for adding perspective to our scene.
        glLoadIdentity # Resets current modelview matrix

        # Calculates aspect ratio of the window. Gets perspective  view. 45 is degree viewing angle, (0.1, 100) are ranges how deep can we draw into the screen
        gluPerspective(90.0, width / height, 0.1, 1000.0)
        glMatrixMode(GL_MODELVIEW) # The modelview matrix is where object information is stored.
        glLoadIdentity

        @camera_light.draw
        glEnable(GL_DEPTH_TEST)

        glRotatef(@angle_y,1,0,0)
        glRotatef(@angle_x,0,1,0)
        glTranslatef(@camera.x, @camera.y, @camera.z)
        # gluLookAt(@camera.x,@camera.y,@camera.z, @angle_x,@angle_y,0, 0,1,0)

        color = [@c1, @c2, @c3]
        @skydome.draw(0,0,0, 0.004, false) if @draw_skydome
        @scene.draw(0,0,0, 1)
        @model.draw(1, 0, 0)
        @tree.draw(5, 0, 0)
        @tree.draw(5, 0, 3)
        @tree.draw(3, 0, 10)
        # @mega_model.draw(0,0,0, 1)
      end

      @text.split("~").each_with_index do |bit, i|
        @font.draw(bit.strip, 10, @font.height*i, Float::INFINITY)
      end
    end

    def update
      @text = "OpenGL Vendor: #{glGetString(GL_VENDOR)}~
      OpenGL Renderer: #{glGetString(GL_RENDERER)} ~
      OpenGL Version: #{glGetString(GL_VERSION)}~
      OpenGL Shader Language Version: #{glGetString(GL_SHADING_LANGUAGE_VERSION)}~
      ~
      Angle Y: #{@angle_y.round(2)} Angle X: #{@angle_x.round(2)} ~
      X:#{@camera.x.round(2)} Y:#{@camera.y.round(2)} Z:#{@camera.z.round(2)} ~
      Faces: #{@number_of_faces} ~
      Last Frame: #{Gosu.milliseconds-@last_frame_time}ms (#{Gosu.fps} fps)~
      ~
      Draw Skydome: #{@draw_skydome}"
      @last_frame_time = Gosu.milliseconds

      # $window.caption = "Gosu OBJ object - FPS:#{Gosu.fps}"
      @angle_x-=Float(@mouse.x-self.mouse_x)/@mouse_sesitivity
      @angle_y-=Float(@mouse.y-self.mouse_y)/@mouse_sesitivity
      @angle_x %= 360.0
      @angle_y = @angle_y.clamp(-90.0, 90.0)
      self.mouse_x, self.mouse_y = Gosu.screen_width/2, Gosu.screen_height/2

      @light_postion = [@camera.x, @camera.y, @camera.z, 0]
      @camera_light.postion = @light_postion
      # @light_postion = [0.0, 10, 0, 0]

      relative_speed = @speed*(delta_time/60.0)

      if button_down?(Gosu::KbUp) || button_down?(Gosu::KbW)
        @camera.z+=Math.cos(@angle_x * Math::PI / 180)*relative_speed
        @camera.x-=Math.sin(@angle_x * Math::PI / 180)*relative_speed
      end
      if button_down?(Gosu::KbDown) || button_down?(Gosu::KbS)
        @camera.z-=Math.cos(@angle_x * Math::PI / 180)*relative_speed
        @camera.x+=Math.sin(@angle_x * Math::PI / 180)*relative_speed
      end
      if button_down?(Gosu::KbLeft) || button_down?(Gosu::KbA)
        @camera.z+=Math.sin(@angle_x * Math::PI / 180)*relative_speed
        @camera.x+=Math.cos(@angle_x * Math::PI / 180)*relative_speed
      end
      if button_down?(Gosu::KbRight) || button_down?(Gosu::KbD)
        @camera.z-=Math.sin(@angle_x * Math::PI / 180)*relative_speed
        @camera.x-=Math.cos(@angle_x * Math::PI / 180)*relative_speed
      end

      @camera.y+=relative_speed if $window.button_down?(Gosu::KbLeftShift)
      @camera.y-=relative_speed if $window.button_down?(Gosu::KbSpace)

      $window.close if $window.button_down?(Gosu::KbEscape)
      @number_of_faces = 0
    end

    def button_up(id)
      case id
      when Gosu::KbZ
        @draw_skydome = !@draw_skydome
      end
    end

    def delta_time
      t = Gosu.milliseconds-@delta_time
      @delta_time = Gosu.milliseconds
      return t
    end
  end
end
