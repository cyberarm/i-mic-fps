class IMICFPS
  module CommonMethods

    def delta_time; $window.delta_time; end
    def button_down?(id); $window.button_down?(id); end

    def mouse_x; $window.mouse_x; end
    def mouse_y; $window.mouse_y; end
    def mouse_x=int; $window.mouse_x=int; end
    def mouse_y=int; $window.mouse_y=int; end
  end
end
