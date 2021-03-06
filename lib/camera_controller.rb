# frozen_string_literal: true

class IMICFPS
  class CameraController
    include CommonMethods

    attr_accessor :mode, :camera, :entity, :distance, :origin_distance,
                  :constant_pitch, :mouse_sensitivity, :mouse_captured

    def initialize(camera:, entity: nil, mode: :fpv)
      # :fpv - First Person View
      # :tpv - Third Person View
      @mode = mode
      @camera = camera
      @entity = entity

      @distance = 4
      @origin_distance = @distance
      @constant_pitch = 20.0

      window.mouse_x = window.width / 2
      window.mouse_y = window.height / 2

      @true_mouse = Point.new(window.width / 2, window.height / 2)
      @mouse_sensitivity = 20.0 # Less is faster, more is slower
      @mouse_captured = true
      @mouse_checked = 0
    end

    def first_person_view?
      @mode == :fpv
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
      @distance = if first_person_view?
                    0
                  else
                    @origin_distance
                  end

      x_offset = horizontal_distance_from_object * Math.sin(@entity.orientation.y.degrees_to_radians)
      z_offset = horizontal_distance_from_object * Math.cos(@entity.orientation.y.degrees_to_radians)

      eye_height = @entity.normalize_bounding_box.max.y

      @camera.position.x = @entity.position.x - x_offset
      @camera.position.y = @entity.position.y + eye_height
      @camera.position.z = @entity.position.z - z_offset

      @camera.orientation.y = 180 - @entity.orientation.y
    end

    def update
      position_camera if @entity

      return unless @mouse_captured

      delta = Float(@true_mouse.x - mouse_x) / (@mouse_sensitivity * @camera.field_of_view) * 70
      @camera.orientation.y -= delta
      @camera.orientation.y %= 360.0

      @camera.orientation.x -= Float(@true_mouse.y - window.mouse_y) / (@mouse_sensitivity * @camera.field_of_view) * 70
      @camera.orientation.x = @camera.orientation.x.clamp(-90.0, 90.0)

      if @entity
        @entity.orientation.y += delta
        @entity.orientation.y %= 360.0
      end

      window.mouse_x = window.width  / 2 if window.mouse_x <= 1 || window.mouse_x >= window.width  - 1
      window.mouse_y = window.height / 2 if window.mouse_y <= 1 || window.mouse_y >= window.height - 1
      @true_mouse.x = window.mouse_x
      @true_mouse.y = window.mouse_y
    end

    def button_down(id)
      actions = InputMapper.actions(id)

      if actions.include?(:release_mouse)
        @mouse_captured = false
        window.needs_cursor = true
      elsif actions.include?(:capture_mouse)
        @mouse_captured = true
        window.needs_cursor = false

      elsif actions.include?(:decrease_view_distance)
        @camera.max_view_distance -= 0.5
      elsif actions.include?(:increase_view_distance)
        @camera.max_view_distance += 0.5
      elsif actions.include?(:toggle_first_person_view)
        @mode = first_person_view? ? :tpv : :fpv
        @entity.visible = !first_person_view? if @entity
      elsif actions.include?(:turn_180)
        @entity.orientation.y += 180 if @entity
        @entity.orientation.y %= 360.0 if @entity
      end
    end

    def button_up(id)
    end

    def free_move
      relative_y_rotation = (@camera.orientation.y + 180)
      relative_speed = 2.5
      relative_speed = 1.5 if InputMapper.down?(:sneak)
      relative_speed = 10.0 if InputMapper.down?(:sprint)
      relative_speed *= window.dt

      if InputMapper.down?( :forward)
        @camera.position.z += Math.cos(relative_y_rotation * Math::PI / 180) * relative_speed
        @camera.position.x -= Math.sin(relative_y_rotation * Math::PI / 180) * relative_speed
      end

      if InputMapper.down?(:backward)
        @camera.position.z -= Math.cos(relative_y_rotation * Math::PI / 180) * relative_speed
        @camera.position.x += Math.sin(relative_y_rotation * Math::PI / 180) * relative_speed
      end

      if InputMapper.down?(:strife_left)
        @camera.position.z += Math.sin(relative_y_rotation * Math::PI / 180) * relative_speed
        @camera.position.x += Math.cos(relative_y_rotation * Math::PI / 180) * relative_speed
      end

      if InputMapper.down?(:strife_right)
        @camera.position.z -= Math.sin(relative_y_rotation * Math::PI / 180) * relative_speed
        @camera.position.x -= Math.cos(relative_y_rotation * Math::PI / 180) * relative_speed
      end

      if InputMapper.down?(:ascend)
        @camera.position.y += relative_speed
      end
      if InputMapper.down?(:descend)
        @camera.position.y -= relative_speed
      end
    end
  end
end
