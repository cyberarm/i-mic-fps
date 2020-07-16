class IMICFPS
  class Window < CyberarmEngine::Window
    attr_accessor :number_of_vertices, :needs_cursor
    attr_reader :renderer, :scene, :config

    attr_reader :console, :delta_time
    def initialize(window_width = 1280, window_height = 720, fullscreen = false)
      fps_target = (ARGV.first.to_i != 0) ? ARGV.first.to_i : 60
      if ARGV.join.include?("--native")
        super(width: Gosu.screen_width, height: Gosu.screen_height, fullscreen: true, resizable: true, update_interval: 1000.0/fps_target)
      else
        super(width: window_width, height: window_height, fullscreen: fullscreen, resizable: true, update_interval: 1000.0/fps_target)
      end
      $window = self
      @needs_cursor = false
      @cursor = Gosu::Image.new(IMICFPS::GAME_ROOT_PATH + "/static/cursors/pointer.png")
      @number_of_vertices = 0

      self.caption = "#{IMICFPS::NAME} v#{IMICFPS::VERSION} (#{IMICFPS::RELEASE_NAME})"

      @config = CyberarmEngine::ConfigFile.new(file: IMICFPS::GAME_ROOT_PATH + "/data/config.json")
      @show_console = false
      @console = Console.new
      Commands::Command.setup

      @renderer = Renderer.new
      preload_default_shaders
      @scene = TurnTableScene.new
      @overlay = Overlay.new

      @canvas_size = Vector.new(self.width, self.height)

      at_exit do
        @config.save!
      end

      push_state(Boot)

      @delta_time = Gosu.milliseconds
    end

    def preload_default_shaders
      shaders = ["g_buffer", "lighting"]
      shaders.each do |shader|
        Shader.new(
          name: shader,
          includes_dir: "shaders/include",
          vertex: "shaders/vertex/#{shader}.glsl",
          fragment: "shaders/fragment/#{shader}.glsl"
        )
      end
    end

    def needs_cursor?
      false
    end

    def draw
      super

      @console.draw if @show_console
      @overlay.draw
      draw_cursor if needs_cursor

      _canvas_size = Vector.new(self.width, self.height)
      if @canvas_size != _canvas_size
        @renderer.canvas_size_changed
        @canvas_size = _canvas_size
      end
    end

    def draw_cursor
      size = 16

      @cursor.draw(mouse_x, mouse_y, Float::INFINITY)
    end

    def update
      super

      @console.update if @show_console
      @overlay.update
      SoundManager.update

      @number_of_vertices = 0
      @delta_time = Gosu.milliseconds
    end

    def close
      push_state(Close)
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
