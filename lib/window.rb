class IMICFPS
  class Window < Gosu::Window
    include GL
    include GLU
    include GLUT

    def initialize(window_width = 1280, window_height = 800, fullscreen = false)
      # super(window_width, window_height, fullscreen)
      super(Gosu.screen_width, Gosu.screen_height, true)
      $window = self
      @level = Object.new("objects/cube.obj")
      # @level = Object.new("objects/sponza.obj")
      @camera = Object::Vertex.new(0,-1,0)
      @camera_target = Object::Vertex.new(0,-1,0)
      @speed = 0.05
      @angle_y = 0 # |
      @angle_x = 0 # _
      @mouse = Object::Vertex.new(Gosu.screen_width/2,Gosu.screen_height/2,0)
      self.mouse_x, self.mouse_y = Gosu.screen_width/2, Gosu.screen_height/2

      @font = Gosu::Font.new(18, name: "DejaVu Sans")
      @text = "Hello There"
      @last_frame_time = 0
      @tick = 0
      @c1, @c2, @c3 = rand(0.0..1.0), rand(0.0..1.0), rand(0.0..1.0)

      @ambient_light = [0, 0, 0, 1]
      @diffuse_light = [1, 1, 1, 1]
      @specular_light = [1, 1, 1, 1]
      @light_postion = [1, 1, 1, 0]

      # gl do
        #
      # end
    end

    def draw
      gl do
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) # clear the screen and the depth buffer
        glShadeModel(GL_SMOOTH)

        #glMatrixMode(matrix) indicates that following [matrix] is going to get used
        glMatrixMode(GL_PROJECTION) # The projection matrix is responsible for adding perspective to our scene.
        glLoadIdentity # Resets current modelview matrix

        # Calculates aspect ratio of the window. Gets perspective  view. 45 is degree viewing angle, (0.1, 100) are ranges how deep can we draw into the screen
        gluPerspective(90.0, width / height, 0.1, 100.0)
        glMatrixMode(GL_MODELVIEW) # The modelview matrix is where object information is stored.
        glLoadIdentity
        # Think 3-d coordinate system (x,y,z). +- on each movies on that axis
        glLightfv(GL_LIGHT0, GL_AMBIENT, @ambient_light)
        glLightfv(GL_LIGHT0, GL_DIFFUSE, @diffuse_light)
        glLightfv(GL_LIGHT0, GL_SPECULAR, @specular_light)
        glLightfv(GL_LIGHT0, GL_POSITION, @light_postion)
        glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER, 1)
        glEnable(GL_LIGHTING)
        glEnable(GL_LIGHT0)
        glEnable(GL_DEPTH_TEST)
        glEnable(GL_CULL_FACE)

        glEnable(GL_COLOR_MATERIAL)
        glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)

        # glRotatef(@angle_y,0,1,0)
        # glRotatef(@angle_x,1,0,0)
        # glTranslate(@x, @y, @z)
        # glPointSize(5.0)
        gluLookAt(@camera.x,@camera.y,@camera.z, @angle_x,@angle_y,0, 0,1,0)

        color = [@c1, @c2, @c3]
        glBegin(GL_TRIANGLES) # begin drawing model
          @level.faces.each do |vert|
            vertex = vert[0]
            normal = vert[1]

            glColor3f(color[0], color[1], color[2])
            glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, [@c1, @c2, @c3, 1.0])
            glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, [@c1, @c2, @c3, 1.0])
            glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, [1,1,1,1])
            glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, [10.0])

            glNormal3f(normal.x, normal.y, normal.z)
            glVertex3f(vertex.x, vertex.y, vertex.z)
          end
        glEnd
      end

      @text.split("~").each_with_index do |bit, i|
        @font.draw(bit.strip, 10, @font.height*i, Float::INFINITY)
      end
    end

    def update
      @text = "Open Vendor: #{glGetString(GL_VENDOR)}~
      OpenGL Renderer: #{glGetString(GL_RENDERER)} ~
      OpenGL Version: #{glGetString(GL_VERSION)}~
      OpenGL Shader Language Version: #{glGetString(GL_SHADING_LANGUAGE_VERSION)}~
      ~
      Angle Y: #{@angle_y} Angle X: #{@angle_x} ~
      X:#{@camera.x} Y:#{@camera.y} Z:#{@camera.z} ~
      Mesh Vert Array: #{@level.faces.size} ~
      Last Frame: #{Gosu.milliseconds-@last_frame_time}ms (#{Gosu.fps} fps)"
      @last_frame_time = Gosu.milliseconds

      # $window.caption = "Gosu OBJ Level - FPS:#{Gosu.fps}"
      @angle_x-=Integer(@mouse.x-self.mouse_x)
      @angle_y-=Integer(@mouse.y-self.mouse_y)
      @angle_x = @angle_x.clamp(-360, 360)
      @angle_y = @angle_y.clamp(-360, 360)
      self.mouse_x, self.mouse_y = Gosu.screen_width/2, Gosu.screen_height/2

      @light_postion = [-@camera.x, -@camera.y, -@camera.z, 1]
      # @light_postion = [1.0, 0.249, 4.09, 1]

      @camera.x-=@speed if $window.button_down?(Gosu::KbRight)
      @camera.x+=@speed if $window.button_down?(Gosu::KbLeft)
      @camera.z+=@speed if $window.button_down?(Gosu::KbUp)
      @camera.z-=@speed if $window.button_down?(Gosu::KbDown)

      @camera.y+=@speed if $window.button_down?(Gosu::KbLeftShift)
      @camera.y-=@speed if $window.button_down?(Gosu::KbSpace)

      $window.close if $window.button_down?(Gosu::KbEscape)
    end
  end
end
