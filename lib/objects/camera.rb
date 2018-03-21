class IMICFPS
  class Camera
    include CommonMethods
    include OpenGL
    include GLU

    attr_accessor :x,:y,:z, :field_of_view, :vertical_angle, :horizontal_angle, :mouse_sensitivity
    def initialize(x: 0, y: 0, z: 0, fov: 70.0)
      @x,@y,@z = x,y,z
      @vertical_angle = 0.0
      @horizontal_angle = 0.0
      @field_of_view = fov

      @speed = 0.05
      @old_speed = @speed
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
      gluPerspective(@field_of_view, $window.width / $window.height, 0.1, 1000.0)
      glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)

      glMatrixMode(GL_MODELVIEW) # The modelview matrix is where object information is stored.
      glLoadIdentity

      glEnable(GL_DEPTH_TEST)

      glRotatef(@vertical_angle,1,0,0)
      glRotatef(@horizontal_angle,0,1,0)
      glTranslatef(@x, @y, @z)
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

      relative_speed = @speed
      if button_down?(Gosu::KbLeftControl)
        relative_speed = (@speed*10.0)*(delta_time/60.0)
      else
        relative_speed = @speed*(delta_time/60.0)
      end

      if button_down?(Gosu::KbUp) || button_down?(Gosu::KbW)
        @z+=Math.cos(@horizontal_angle * Math::PI / 180)*relative_speed
        @x-=Math.sin(@horizontal_angle * Math::PI / 180)*relative_speed
      end
      if button_down?(Gosu::KbDown) || button_down?(Gosu::KbS)
        @z-=Math.cos(@horizontal_angle * Math::PI / 180)*relative_speed
        @x+=Math.sin(@horizontal_angle * Math::PI / 180)*relative_speed
      end
      if button_down?(Gosu::KbA)
        @z+=Math.sin(@horizontal_angle * Math::PI / 180)*relative_speed
        @x+=Math.cos(@horizontal_angle * Math::PI / 180)*relative_speed
      end
      if button_down?(Gosu::KbD)
        @z-=Math.sin(@horizontal_angle * Math::PI / 180)*relative_speed
        @x-=Math.cos(@horizontal_angle * Math::PI / 180)*relative_speed
      end

      if button_down?(Gosu::KbLeft)
        @horizontal_angle-=relative_speed*100
      end
      if button_down?(Gosu::KbRight)
        @horizontal_angle+=relative_speed*100
      end

      @y+=relative_speed if button_down?(Gosu::KbC) || button_down?(Gosu::KbLeftShift)
      @y-=relative_speed if button_down?(Gosu::KbSpace)
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
        @field_of_view += 1
        @field_of_view = @field_of_view.clamp(1, 179)
      when Gosu::MsWheelDown
        @field_of_view -= 1
        @field_of_view = @field_of_view.clamp(1, 179)
      end
    end
  end
end
