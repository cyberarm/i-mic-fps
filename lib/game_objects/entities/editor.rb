# frozen_string_literal: true

class IMICFPS
  class Editor < Entity
    attr_accessor :speed
    attr_reader :bound_model, :first_person_view

    def setup
      bind_model
      @speed = 2.5 # meter's per second
      @running_speed = 5.0 # meter's per second
      @turn_speed = 50.0
      @old_speed = @speed
      @mass = 72 # kg
      @first_person_view = true
      @visible = false
      @drag = 0.9
    end

    def update
      super

      @position += @velocity * window.dt
      @velocity *= @drag
    end

    def relative_speed
      InputMapper.down?(:sprint) ? @running_speed : @speed
    end

    def relative_y_rotation
      @orientation.y * -1
    end

    def forward
      @velocity.z += Math.cos(relative_y_rotation * Math::PI / 180) * relative_speed
      @velocity.y -= Math.sin(@orientation.x * Math::PI / 180) * relative_speed
      @velocity.x -= Math.sin(relative_y_rotation * Math::PI / 180) * relative_speed
    end

    def backward
      @velocity.z -= Math.cos(relative_y_rotation * Math::PI / 180) * relative_speed
      @velocity.y += Math.sin(@orientation.x * Math::PI / 180) * relative_speed
      @velocity.x += Math.sin(relative_y_rotation * Math::PI / 180) * relative_speed
    end

    def strife_left
      @velocity.z += Math.sin(relative_y_rotation * Math::PI / 180) * relative_speed
      @velocity.x += Math.cos(relative_y_rotation * Math::PI / 180) * relative_speed
    end

    def strife_right
      @velocity.z -= Math.sin(relative_y_rotation * Math::PI / 180) * relative_speed
      @velocity.x -= Math.cos(relative_y_rotation * Math::PI / 180) * relative_speed
    end

    def turn_left
      @orientation.y += @turn_speed * delta_time
    end

    def turn_right
      @orientation.y -= @turn_speed * delta_time
    end

    def ascend
      @velocity.y += relative_speed
    end

    def descend
      @velocity.y -= relative_speed
    end

    def toggle_first_person_view
      @first_person_view = !@first_person_view
      @visible = !@first_person_view
    end

    def turn_180
      @orientation.y = @orientation.y + 180
      @orientation.y %= 360
    end
  end
end
