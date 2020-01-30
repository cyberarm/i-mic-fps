class IMICFPS
  def self.assets_path
    File.expand_path("./../../assets", __FILE__)
  end

  module CommonMethods

    def window; $window; end

    def delta_time; (Gosu.milliseconds - window.delta_time) / 1000.0; end
    def button_down?(id); window.button_down?(id); end

    def mouse_x; window.mouse_x; end
    def mouse_y; window.mouse_y; end
    def mouse_x=(int); window.mouse_x = int; end
    def mouse_y=(int); window.mouse_y = int; end

    def gl(&block)
      window.gl do
        block.call
      end
    end

    def formatted_number(number)
      string = number.to_s.reverse.scan(/\d{1,3}/).join(",").reverse

      string.insert(0, "-") if number < 0

      return string
    end

    def control_down?; button_down?(Gosu::KbLeftControl) || button_down?(Gosu::KbRightControl); end
    def shift_down?; button_down?(Gosu::KbLeftShift) || button_down?(Gosu::KbRightShift); end
    def alt_down?; button_down?(Gosu::KbLeftAlt) || button_down?(Gosu::KbRightAlt); end

    def draw_rect(*args)
      window.draw_rect(*args)
    end
    def draw_quad(*args)
      window.draw_quad(*args)
    end
    def fill(color = Gosu::Color::WHITE)
      draw_rect(0, 0, window.width, window.height, color)
    end

    def gl_error?
      e = glGetError()
      if e != GL_NO_ERROR
        $stderr.puts "OpenGL error detected by handler at: #{caller[0]}"
        $stderr.puts "    #{gluErrorString(e)} (#{e})\n"
        exit if window.config.get(:debug_options, :opengl_error_panic)
      end
    end
  end
end
