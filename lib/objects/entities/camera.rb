class IMICFPS
  class Camera
    include CommonMethods
    include OpenGL
    include GLU

    attr_accessor :field_of_view, :pitch, :yaw, :roll, :mouse_sensitivity
    attr_reader :entity, :position
    def initialize(x: 0, y: 0, z: 0, fov: 70.0, view_distance: 100.0)
      @position = Vector.new(x,y,z)
      @pitch = 0.0
      @yaw   = 0.0
      @roll  = 0.0
      @field_of_view = fov
      @view_distance = view_distance
      @constant_pitch = 20.0

      @entity = nil
      @distance = 4
      @origin_distance = @distance

      self.mouse_x, self.mouse_y = $window.width/2, $window.height/2
      @true_mouse = Point.new($window.width/2, $window.height/2)
      @mouse_sensitivity = 20.0 # Less is faster, more is slower
      @mouse_captured = true
      @mouse_checked = 0

      InputMapper.set(:camera, :ascend,  Gosu::KbSpace)
      InputMapper.set(:camera, :descend, [Gosu::KbLeftControl, Gosu::KbRightControl])
      InputMapper.set(:camera, :release_mouse, [Gosu::KbLeftAlt, Gosu::KbRightAlt])
      InputMapper.set(:camera, :capture_mouse, Gosu::MsLeft)
      InputMapper.set(:camera, :turn_180, Gosu::KbX)
      InputMapper.set(:camera, :increase_mouse_sensitivity, Gosu::KB_NUMPAD_PLUS)
      InputMapper.set(:camera, :decrease_mouse_sensitivity, Gosu::KB_NUMPAD_MINUS)
      InputMapper.set(:camera, :reset_mouse_sensitivity, Gosu::KB_NUMPAD_MULTIPLY)
      InputMapper.set(:camera, :increase_view_distance, Gosu::MsWheelUp)
      InputMapper.set(:camera, :decrease_view_distance, Gosu::MsWheelDown)
    end

    def attach_to(entity)
      raise "Not a game object!" unless entity.is_a?(Entity)
      @entity = entity
    end

    def detach
      @entity = nil
    end

    def distance_from_object
      @distance
    end

    def horizontal_distance_from_object
      distance_from_object * Math.cos(@constant_pitch)
    end

    def vertical_distance_from_object
      distance_from_object * Math.sin(@constant_pitch)
    end

    def position_camera
      if defined?(@entity.first_person_view)
        if @entity.first_person_view
          @distance = 0
        else
          @distance = @origin_distance
        end
      end

      x_offset = horizontal_distance_from_object * Math.sin(@entity.rotation.y.degrees_to_radians)
      z_offset = horizontal_distance_from_object * Math.cos(@entity.rotation.y.degrees_to_radians)
      # p @entity.x, @entity.z;exit
      @position.x = @entity.position.x - x_offset
      @position.y = @entity.position.y + 2
      @position.z = @entity.position.z - z_offset

      # @yaw = 180 - @entity.y_rotation
      @entity.rotation.y = -@yaw + 180
    end

    def draw
      #glMatrixMode(matrix) indicates that following [matrix] is going to get used
      glMatrixMode(GL_PROJECTION) # The projection matrix is responsible for adding perspective to our scene.
      glLoadIdentity # Resets current modelview matrix
      # Calculates aspect ratio of the window. Gets perspective  view. 45 is degree viewing angle, (0.1, 100) are ranges how deep can we draw into the screen
      gluPerspective(@field_of_view, $window.width / $window.height, 0.1, @view_distance)
      glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)
      glRotatef(@pitch,1,0,0)
      glRotatef(@yaw,0,1,0)
      glTranslatef(-@position.x, -@position.y, -@position.z)
      glMatrixMode(GL_MODELVIEW) # The modelview matrix is where object information is stored.
      glLoadIdentity

      # if $debug && @entity
      #   glBegin(GL_LINES)
      #     glColor3f(1,0,0)
      #     glVector3f(@x, @y, @z)
      #     glVector3f(@entity.x, @entity.y, @entity.z)
      #   glEnd
      # end
    end

    def update
      if @mouse_captured
        position_camera if @entity

        delta = Float(@true_mouse.x-self.mouse_x)/(@mouse_sensitivity*@field_of_view)*70
        @yaw -= delta
        @yaw %= 360.0

        @pitch -= Float(@true_mouse.y-self.mouse_y)/(@mouse_sensitivity*@field_of_view)*70
        @pitch = @pitch.clamp(-90.0, 90.0)

        @entity.rotation.y += delta if @entity
        free_move unless @entity

        self.mouse_x = $window.width/2 if self.mouse_x <= 1 || $window.mouse_x >= $window.width-1
        self.mouse_y = $window.height/2 if self.mouse_y <= 1 || $window.mouse_y >= $window.height-1
        @true_mouse.x, @true_mouse.y = self.mouse_x, self.mouse_y
      end
    end

    def free_move
      relative_y_rotation = (@yaw + 180)
      relative_speed = 0.5

      if InputMapper.down?(:character, :forward)
        @z+=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
        @x-=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
      end

      if InputMapper.down?(:character, :backward)
        @z-=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
        @x+=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
      end

      if InputMapper.down?(:character, :strife_left)
        @z+=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
        @x+=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
      end

      if InputMapper.down?(:character, :strife_right)
        @z-=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
        @x-=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
      end

      if InputMapper.down?(:camera, :ascend)
        @y+=relative_speed
      end
      if InputMapper.down?(:camera, :descend)
        @y-=relative_speed
      end
    end

    def button_up(id)
      if InputMapper.is?(:camera, :release_mouse, id)
        @mouse_captured = false
        $window.needs_cursor = true
      elsif InputMapper.is?(:camera, :capture_mouse, id)
        @mouse_captured = true
        $window.needs_cursor = false
      elsif InputMapper.is?(:camera, :increase_mouse_sensitivity, id)
        @mouse_sensitivity+=1
        @mouse_sensitivity = @mouse_sensitivity.clamp(1.0, 100.0)
      elsif InputMapper.is?(:camera, :decrease_mouse_sensitivity, id)
        @mouse_sensitivity-=1
        @mouse_sensitivity = @mouse_sensitivity.clamp(1.0, 100.0)
      elsif InputMapper.is?(:camera, :reset_mouse_sensitivity, id)
        @mouse_sensitivity = 20.0
      elsif InputMapper.is?(:camera, :increase_view_distance, id)
        # @field_of_view += 1
        # @field_of_view = @field_of_view.clamp(1, 100)
        @view_distance += 1
        @view_distance = @view_distance.clamp(1, 1000)
      elsif InputMapper.is?(:camera, :decrease_view_distance, id)
        # @field_of_view -= 1
        # @field_of_view = @field_of_view.clamp(1, 100)
        @view_distance -= 1
        @view_distance = @view_distance.clamp(1, 1000)
      elsif InputMapper.is?(:camera, :turn_180, id)
        @rotation.y = @rotation.y+180
        @rotation.y %= 360
      end
    end
  end
end
