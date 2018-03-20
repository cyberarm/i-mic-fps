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
      Model.new(type: :obj, file_path: "objects/skydome.obj", x: 0, y: 0,z: 0, scale: 1, backface_culling: false)
      Model.new(type: :obj, file_path: "objects/cube.obj", x: 0,y: 1,z: -2, scale: 0.0005)
      Model.new(type: :obj, file_path: "objects/biped.obj", x: 1, y: 0, z: 0)
      Model.new(type: :obj, file_path: "objects/tree.obj", x: 3)
      Model.new(type: :obj, file_path: "objects/tree.obj", z: -5)
      Model.new(type: :obj, file_path: "objects/tree.obj", x: -2, z: -6)
      Model.new(type: :obj, file_path: "objects/sponza.obj", scale: 1, y: -0.2)

      @camera = Vertex.new(0,-1,0)
      @camera_target = Vertex.new(0,-1,0)
      @speed = 0.05
      @old_speed = @speed
      @vertical_angle = 0.0 # |
      @horizontal_angle = 0.0 # _
      self.mouse_x, self.mouse_y = Gosu.screen_width/2, Gosu.screen_height/2
      @true_mouse = Point.new(Gosu.screen_width/2, Gosu.screen_height/2)
      @true_mouse_checked = 0
      @mouse_sesitivity = 20.0
      @initial_fov = 70.0

      @crosshair_size = 10
      @crosshair_thickness = 3
      @crosshair_color = Gosu::Color.rgb(255,127,0)

      @font = Gosu::Font.new(18, name: "DejaVu Sans")
      @text = "Hello There"

      @ambient_light = [0.5, 0.5, 0.5, 1]
      @diffuse_light = [1, 0.5, 0, 1]
      @specular_light = [0.2, 0.2, 0.2, 1]
      @light_position = [3, 6, 6, 0]

      @camera_light = Light.new(0,0,0)
      @camera_light.ambient = @ambient_light
      @camera_light.diffuse = @diffuse_light
      @camera_light.specular = @specular_light
      @camera_light.position = @light_position
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
        gluPerspective(@initial_fov, width / height, 0.1, 1000.0)
        glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)

        glMatrixMode(GL_MODELVIEW) # The modelview matrix is where object information is stored.
        glLoadIdentity

        glEnable(GL_DEPTH_TEST)
        @camera_light.draw

        glRotatef(@vertical_angle,1,0,0)
        glRotatef(@horizontal_angle,0,1,0)
        glTranslatef(@camera.x, @camera.y, @camera.z)
        # gluLookAt(@camera.x,@camera.y,@camera.z, @horizontal_angle,@vertical_angle,0, 0,1,0)

        ObjectManager.objects.each do |object|
          object.draw if object.visible && object.renderable
        end
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
      Vertical Angle: #{@vertical_angle.round(2)} Horizontal Angle: #{@horizontal_angle.round(2)} ~
      X:#{@camera.x.round(2)} Y:#{@camera.y.round(2)} Z:#{@camera.z.round(2)} ~
      FOV: #{@initial_fov} ~
      Faces: #{@number_of_faces} ~
      Last Frame: #{delta_time}ms (#{Gosu.fps} fps)~
      ~
      Draw Skydome: #{@draw_skydome}~
      Debug mode: <c=992200>#{$debug}</b>~"

      ObjectManager.objects.each do |object|
        object.update
      end

      if @true_mouse_checked > 2
        @horizontal_angle-=Float(@true_mouse.x-self.mouse_x)/@mouse_sesitivity
        @vertical_angle-=Float(@true_mouse.y-self.mouse_y)/@mouse_sesitivity
        @horizontal_angle %= 360.0
        @vertical_angle = @vertical_angle.clamp(-90.0, 90.0)
      else
        @true_mouse_checked+=1
        @true_mouse.x = self.mouse_x
        @true_mouse.y = self.mouse_y
      end

      self.mouse_x, self.mouse_y = Gosu.screen_width/2.0, Gosu.screen_height/2.0
      @true_mouse_checked = 0 if (button_down?(Gosu::KbLeftAlt) && (button_down?(Gosu::KbEnter) || button_down?(Gosu::KbReturn)))
      @true_mouse_checked = 0 if (button_down?(Gosu::KbRightAlt) && (button_down?(Gosu::KbEnter) || button_down?(Gosu::KbReturn)))

      relative_speed = @speed
      if button_down?(Gosu::KbLeftControl)
        relative_speed = (@speed*10.0)*(delta_time/60.0)
      else
        relative_speed = @speed*(delta_time/60.0)
      end

      if button_down?(Gosu::KbUp) || button_down?(Gosu::KbW)
        @camera.z+=Math.cos(@horizontal_angle * Math::PI / 180)*relative_speed
        @camera.x-=Math.sin(@horizontal_angle * Math::PI / 180)*relative_speed
      end
      if button_down?(Gosu::KbDown) || button_down?(Gosu::KbS)
        @camera.z-=Math.cos(@horizontal_angle * Math::PI / 180)*relative_speed
        @camera.x+=Math.sin(@horizontal_angle * Math::PI / 180)*relative_speed
      end
      if button_down?(Gosu::KbA)
        @camera.z+=Math.sin(@horizontal_angle * Math::PI / 180)*relative_speed
        @camera.x+=Math.cos(@horizontal_angle * Math::PI / 180)*relative_speed
      end
      if button_down?(Gosu::KbD)
        @camera.z-=Math.sin(@horizontal_angle * Math::PI / 180)*relative_speed
        @camera.x-=Math.cos(@horizontal_angle * Math::PI / 180)*relative_speed
      end

      if button_down?(Gosu::KbLeft)
        @horizontal_angle-=relative_speed*100
      end
      if button_down?(Gosu::KbRight)
        @horizontal_angle+=relative_speed*100
      end

      @camera.y+=relative_speed if $window.button_down?(Gosu::KbC) || $window.button_down?(Gosu::KbLeftShift)
      @camera.y-=relative_speed if $window.button_down?(Gosu::KbSpace)

      $window.close if $window.button_down?(Gosu::KbEscape)
      @number_of_faces = 0
      @delta_time = Gosu.milliseconds
    end

    def button_up(id)
      case id
      when Gosu::KbZ
        @draw_skydome = !@draw_skydome
      when Gosu::KbBacktick
        $debug = !$debug
      when Gosu::MsWheelUp
        @initial_fov += 1
        @initial_fov = @initial_fov.clamp(1, 179)
      when Gosu::MsWheelDown
        @initial_fov -= 1
        @initial_fov = @initial_fov.clamp(1, 179)
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
