class IMICFPS
  class Player < Entity

    attr_accessor :speed
    attr_reader :name, :bound_model

    def setup
      bind_model

      @speed = 2.5 # meter's per second
      @running_speed = 5.0 # meter's per second
      @turn_speed = 50.0
      @old_speed = @speed
      @mass = 72 # kg
      @visible = false
      @drag = 0.6
    end

    def update
      # Do not handle movement if mouse is not captured
      return if @camera && !@camera.mouse_captured

      super
    end

    def relative_speed
      InputMapper.down?(:sprint) ? @running_speed : @speed
    end

    def relative_y_rotation
      @orientation.y * -1
    end

    def forward
      @velocity.z += Math.cos(relative_y_rotation * Math::PI / 180) * relative_speed
      @velocity.x -= Math.sin(relative_y_rotation * Math::PI / 180) * relative_speed
    end

    def backward
      @velocity.z -= Math.cos(relative_y_rotation * Math::PI / 180) * relative_speed
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

    def jump
      if InputMapper.down?(:jump) && window.current_state.map.collision_manager.on_ground?(self)
        @velocity.y = 1.5
      end
    end
  end
end
