class IMICFPS
  class Camera
    include CommonMethods
    include OpenGL
    include GLU

    attr_accessor :x,:y,:z, :field_of_view, :vertical_angle, :horizontal_angle, :mouse_sensitivity
    attr_reader :bound_model
    def initialize(x: 0, y: 0, z: 0, fov: 70.0, distance: 100.0)
      @x,@y,@z = x,y,z
      @vertical_angle = 0.0
      @horizontal_angle = 0.0
      @field_of_view = fov
      @view_distance = distance

      self.mouse_x, self.mouse_y = Gosu.screen_width/2, Gosu.screen_height/2
      @true_mouse = Point.new(Gosu.screen_width/2, Gosu.screen_height/2)
      @true_mouse_checked = 0
      @mouse_sensitivity = 20.0
    end

    def draw
      #glMatrixMode(matrix) indicates that following [matrix] is going to get used
      glMatrixMode(GL_PROJECTION) # The projection matrix is responsible for adding perspective to our scene.
      glLoadIdentity # Resets current modelview matrix
      # Calculates aspect ratio of the window. Gets perspective  view. 45 is degree viewing angle, (0.1, 100) are ranges how deep can we draw into the screen
      gluPerspective(@field_of_view, $window.width / $window.height, 0.1, @view_distance)
      glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)
      glRotatef(@vertical_angle,1,0,0)
      glRotatef(@horizontal_angle,0,1,0)
      glTranslatef(@x, @y, @z)

      glMatrixMode(GL_MODELVIEW) # The modelview matrix is where object information is stored.
      glLoadIdentity
    end

    def update
      if @true_mouse_checked > 2
        @horizontal_angle-=Float(@true_mouse.x-self.mouse_x)/(@mouse_sensitivity*@field_of_view)*70
        @vertical_angle-=Float(@true_mouse.y-self.mouse_y)/(@mouse_sensitivity*@field_of_view)*70
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
