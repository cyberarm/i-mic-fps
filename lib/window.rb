class IMICFPS
  GRAVITY = 9.8 # m/s
  class Window < CyberarmEngine::Engine
    attr_accessor :number_of_vertices, :needs_cursor
    attr_reader :camera

    def initialize(window_width = 1280, window_height = 800, fullscreen = false)
      fps_target = (ARGV.first.to_i != 0) ? ARGV.first.to_i : 60
      if ARGV.join.include?("--native")
        super(width: Gosu.screen_width, height: Gosu.screen_height, fullscreen: true, resizable: true, update_interval: 1000.0/fps_target)
      else
        super(width: window_width, height: window_height, fullscreen: fullscreen, resizable: true, update_interval: 1000.0/fps_target)
      end
      $window = self
      @needs_cursor = false
      @number_of_vertices = 0

      self.caption = "#{IMICFPS::NAME} v#{IMICFPS::VERSION} (#{IMICFPS::RELEASE_NAME})"

      @show_console = false
      @console = Console.new

      push_state(MainMenu)
    end

    def draw
      super

      @console.draw if @show_console
    end

    def update
      super

      @console.update if @show_console
    end

    def button_down(id)
      if @show_console
        @console.button_down(id)
      else
        super
      end

      if id == Gosu::KbBacktick
        @show_console ? @console.blur : @console.focus
        @show_console = !@show_console
      end
    end

    def button_up(id)
      if @show_console
        @console.button_up(id)
      else
        super
      end
    end
  end
end
