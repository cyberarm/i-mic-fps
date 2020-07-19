class IMICFPS
  class CameraController
    include CommonMethods

    attr_accessor :mode, :camera, :entity, :distance, :origin_distance,
                  :constant_pitch, :mouse_sensitivity, :mouse_captured
    def initialize(mode: :fpv, camera:, entity:)
      # :fpv - First Person View
      # :tpv - Third Person View
      @mode = mode
      @camera = camera
      @entity = entity

      @distance = 4
      @origin_distance = @distance
      @constant_pitch = 20.0

      window.mouse_x, window.mouse_y = window.width / 2, window.height / 2

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
      if first_person_view?
        @distance = 0
      else
        @distance = @origin_distance
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
      position_camera

      if @mouse_captured
        delta = Float(@true_mouse.x - self.mouse_x) / (@mouse_sensitivity * @camera.field_of_view) * 70
        @camera.orientation.y -= delta
        @camera.orientation.y %= 360.0

        @camera.orientation.x -= Float(@true_mouse.y - window.mouse_y) / (@mouse_sensitivity * @camera.field_of_view) * 70
        @camera.orientation.x = @camera.orientation.x.clamp(-90.0, 90.0)

        @entity.orientation.y += delta
        @entity.orientation.y %= 360.0

        window.mouse_x = window.width  / 2 if window.mouse_x <= 1 || window.mouse_x >= window.width-1
        window.mouse_y = window.height / 2 if window.mouse_y <= 1 || window.mouse_y >= window.height-1
        @true_mouse.x, @true_mouse.y = window.mouse_x, window.mouse_y
      end
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
        @entity.visible = !first_person_view?
      elsif actions.include?(:turn_180)
        @entity.orientation.y += 180
        @entity.orientation.y %= 360.0
      end
    end

    def button_up(id); end
  end
end
