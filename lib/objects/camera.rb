class IMICFPS
  class Camera
    include CommonMethods
    include OpenGL
    include GLU

    attr_accessor :x,:y,:z, :field_of_view, :pitch, :yaw, :roll, :mouse_sensitivity
    attr_reader :game_object
    def initialize(x: 0, y: 0, z: 0, fov: 70.0, distance: 100.0)
      @x,@y,@z = x,y,z
      @pitch = 0.0
      @yaw   = 0.0
      @roll  = 0.0
      @field_of_view = fov
      @view_distance = distance

      @game_object = nil
      @distance = 2

      self.mouse_x, self.mouse_y = Gosu.screen_width/2, Gosu.screen_height/2
      @true_mouse = Point.new(Gosu.screen_width/2, Gosu.screen_height/2)
      @true_mouse_checked = 0
      @mouse_sensitivity = 20.0
    end

    def attach_to(game_object)
      raise "Not a game object!" unless game_object.is_a?(GameObject)
      @game_object = game_object
    end

    def detach
      @game_object = nil
    end

    def distance_from_object
      @distance
    end

    def horizontal_distance_from_object
      distance_from_object * Math.cos(@pitch)
    end

    def vertical_distance_from_object
      distance_from_object * Math.sin(@pitch)
    end

    def position_camera
      x_offset = horizontal_distance_from_object * Math.sin(@game_object.y_rotation.degrees_to_radians)
      z_offset = horizontal_distance_from_object * Math.cos(@game_object.y_rotation.degrees_to_radians)
      # p @game_object.x, @game_object.z;exit
      @x = @game_object.x - x_offset
      @y = @game_object.y - 2
      @z = @game_object.z - z_offset

      @yaw = 180 - @game_object.y_rotation
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
      glTranslatef(@x, @y, @z)

      glMatrixMode(GL_MODELVIEW) # The modelview matrix is where object information is stored.
      glLoadIdentity
    end

    def update
      position_camera if @game_object

      if @true_mouse_checked > 2
        @yaw-=Float(@true_mouse.x-self.mouse_x)/(@mouse_sensitivity*@field_of_view)*70 unless @game_object
        @pitch-=Float(@true_mouse.y-self.mouse_y)/(@mouse_sensitivity*@field_of_view)*70 unless @game_object
        @yaw %= 360.0
        @pitch = @pitch.clamp(-90.0, 90.0)
      else
        @true_mouse_checked+=1
        @true_mouse.x = self.mouse_x
        @true_mouse.y = self.mouse_y
      end

      self.mouse_x, self.mouse_y = Gosu.screen_width/2.0, Gosu.screen_height/2.0
      @true_mouse_checked = 0 if (button_down?(Gosu::KbLeftAlt) && (button_down?(Gosu::KbEnter) || button_down?(Gosu::KbReturn)))
      @true_mouse_checked = 0 if (button_down?(Gosu::KbRightAlt) && (button_down?(Gosu::KbEnter) || button_down?(Gosu::KbReturn)))
    end

    def button_up(id)
      case id
      when Gosu::KB_NUMPAD_PLUS
        @mouse_sensitivity+=1
        @mouse_sensitivity = @mouse_sensitivity.clamp(1.0, 100.0)
      when Gosu::KbMinus, Gosu::KB_NUMPAD_MINUS
        @mouse_sensitivity-=1
        @mouse_sensitivity = @mouse_sensitivity.clamp(1.0, 100.0)
      when Gosu::KB_NUMPAD_MULTIPLY
        @mouse_sensitivity = 20.0
      when Gosu::MsWheelUp
        # @field_of_view += 1
        # @field_of_view = @field_of_view.clamp(1, 100)
        @view_distance += 1
        @view_distance = @view_distance.clamp(1, 1000)
      when Gosu::MsWheelDown
        # @field_of_view -= 1
        # @field_of_view = @field_of_view.clamp(1, 100)
        @view_distance -= 1
        @view_distance = @view_distance.clamp(1, 1000)
      end
    end
  end
end
