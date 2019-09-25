class IMICFPS
  class Camera
    include CommonMethods

    attr_accessor :field_of_view, :mouse_sensitivity
    attr_reader :entity, :position, :orientation, :mouse_captured
    def initialize(position:, orientation: Vector.new(0, 0, 0), fov: 70.0, view_distance: 155.0)
      @position = position
      @orientation = orientation
      @field_of_view = fov
      @view_distance = view_distance
      @constant_pitch = 20.0

      @entity = nil
      @distance = 4
      @origin_distance = @distance

      self.mouse_x, self.mouse_y = window.width / 2, window.height / 2
      @true_mouse = Point.new(window.width / 2, window.height / 2)
      @mouse_sensitivity = 20.0 # Less is faster, more is slower
      @mouse_captured = true
      @mouse_checked = 0
    end

    def attach_to(entity)
      raise "Not an Entity!" unless entity.is_a?(Entity)
      @entity = entity
      @entity.attach_camera(self)
    end

    def detach
      @entity.detach_camera
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

      x_offset = horizontal_distance_from_object * Math.sin(@entity.orientation.y.degrees_to_radians)
      z_offset = horizontal_distance_from_object * Math.cos(@entity.orientation.y.degrees_to_radians)

      @position.x = @entity.position.x - x_offset
      @position.y = @entity.position.y + 2
      @position.z = @entity.position.z - z_offset

      @orientation.y = 180 - @entity.orientation.y
    end

    def draw
      #glMatrixMode(matrix) indicates that following [matrix] is going to get used
      glMatrixMode(GL_PROJECTION) # The projection matrix is responsible for adding perspective to our scene.
      glLoadIdentity # Resets current modelview matrix
      # Calculates aspect ratio of the window. Gets perspective  view. 45 is degree viewing angle, (0.1, 100) are ranges how deep can we draw into the screen
      gluPerspective(@field_of_view, window.width / window.height, 0.1, @view_distance)
      glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)
      glRotatef(@orientation.z, 1, 0, 0)
      glRotatef(@orientation.y, 0, 1, 0)
      glTranslatef(-@position.x, -@position.y, -@position.z)
      glMatrixMode(GL_MODELVIEW) # The modelview matrix is where object information is stored.
      glLoadIdentity

    end

    def update
      if @mouse_captured

        delta = Float(@true_mouse.x - self.mouse_x) / (@mouse_sensitivity * @field_of_view) * 70
        @orientation.y -= delta
        @orientation.y %= 360.0

        @orientation.z -= Float(@true_mouse.y - self.mouse_y) / (@mouse_sensitivity * @field_of_view) * 70
        @orientation.z = @orientation.z.clamp(-90.0, 90.0)

        if @entity
          @entity.orientation.y += delta
          position_camera
        else
          free_move
        end

        self.mouse_x = window.width  / 2 if self.mouse_x <= 1 || window.mouse_x >= window.width-1
        self.mouse_y = window.height / 2 if self.mouse_y <= 1 || window.mouse_y >= window.height-1
        @true_mouse.x, @true_mouse.y = self.mouse_x, self.mouse_y
      end
    end

    def looking_at
      ray = Ray.new(@position, @orientation.direction * -1)
      window.current_state.collision_manager.search(ray)
    end

    def free_move
      relative_y_rotation = (@orientation.y + 180)
      relative_speed = 0.25

      if InputMapper.down?( :forward)
        @position.z+=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
        @position.x-=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
      end

      if InputMapper.down?(:backward)
        @position.z-=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
        @position.x+=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
      end

      if InputMapper.down?(:strife_left)
        @position.z+=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
        @position.x+=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
      end

      if InputMapper.down?(:strife_right)
        @position.z-=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
        @position.x-=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
      end

      if InputMapper.down?(:ascend)
        @position.y+=relative_speed
      end
      if InputMapper.down?(:descend)
        @position.y-=relative_speed
      end
    end

    def button_up(id)
      if InputMapper.is?(:release_mouse, id)
        @mouse_captured = false
        window.needs_cursor = true
      elsif InputMapper.is?(:capture_mouse, id)
        @mouse_captured = true
        window.needs_cursor = false
      elsif InputMapper.is?(:increase_mouse_sensitivity, id)
        @mouse_sensitivity+=1
        @mouse_sensitivity = @mouse_sensitivity.clamp(1.0, 100.0)
      elsif InputMapper.is?(:decrease_mouse_sensitivity, id)
        @mouse_sensitivity-=1
        @mouse_sensitivity = @mouse_sensitivity.clamp(1.0, 100.0)
      elsif InputMapper.is?(:reset_mouse_sensitivity, id)
        @mouse_sensitivity = 20.0
      elsif InputMapper.is?(:increase_view_distance, id)
        # @field_of_view += 1
        # @field_of_view = @field_of_view.clamp(1, 100)
        @view_distance += 1
        @view_distance = @view_distance.clamp(1, 1000)
      elsif InputMapper.is?(:decrease_view_distance, id)
        # @field_of_view -= 1
        # @field_of_view = @field_of_view.clamp(1, 100)
        @view_distance -= 1
        @view_distance = @view_distance.clamp(1, 1000)
      end
    end
  end
end
