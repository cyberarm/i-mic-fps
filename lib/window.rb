class IMICFPS
  GRAVITY = 9.8 # m/s
  class Window < Gosu::Window
    attr_accessor :number_of_faces, :needs_cursor
    attr_reader :camera

    def initialize(window_width = 1280, window_height = 800, fullscreen = false)
      fps_target = (ARGV.first.to_i != 0) ? ARGV.first.to_i : 60
      if ARGV.join.include?("--native")
        super(Gosu.screen_width, Gosu.screen_height, fullscreen: true, resizable: false, update_interval: 1000.0/fps_target)
      else
        super(window_width, window_height, fullscreen: fullscreen, resizable: false, update_interval: 1000.0/fps_target)
      end
      $window = self
      @needs_cursor = false
      @number_of_faces = 0

      @active_state = Game.new
    end

    def draw
      @active_state.draw
    end

    def update
      @active_state.update
    end

    def button_up(id)
      @active_state.button_up(id)
    end
  end
end
