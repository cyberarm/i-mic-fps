# frozen_string_literal: true

class IMICFPS
  class Window < CyberarmEngine::Window
    attr_accessor :needs_cursor
    attr_reader :renderer, :scene, :config, :director, :console, :delta_time

    def setup
      I18n.load_path << Dir["#{GAME_ROOT_PATH}/locales/*.yml"]
      I18n.default_locale = :en
      language = Gosu.language.split("_").first.to_sym
      I18n.locale = language if I18n.available_locales.include?(language)

      @needs_cursor = false
      @cursor = Gosu::Image.new("#{IMICFPS::GAME_ROOT_PATH}/static/cursors/pointer.png")
      @number_of_vertices = 0

      self.caption = "#{IMICFPS::NAME} v#{IMICFPS::VERSION} (#{IMICFPS::RELEASE_NAME})"

      @director = Networking::Director.new

      @config = CyberarmEngine::ConfigFile.new(file: "#{IMICFPS::GAME_ROOT_PATH}/data/config.json")
      @show_console = false
      @console = Console.new
      CyberarmEngine::Console::Command.setup
      @console.stdin("=== #{IMICFPS::NAME} v#{IMICFPS::VERSION} (#{IMICFPS::RELEASE_NAME}) ===\n\n")
      SettingsMenu.set_defaults

      @renderer = Renderer.new
      @scene = TurnTableScene.new
      @overlay = Overlay.new

      @canvas_size = Vector.new(width, height)

      at_exit do
        @config.save!
      end

      push_state(CyberarmEngine::IntroState, forward: Boot)
    end

    def input_hijack=(hijacker)
      @input_hijacker = hijacker

      InputMapper.reset_keys
    end

    def needs_cursor?
      false
    end

    def draw
      super

      @console.draw if @show_console
      @overlay.draw
      draw_cursor if needs_cursor

      _canvas_size = Vector.new(width, height)
      if @canvas_size != _canvas_size
        @renderer = Renderer.new # @renderer.canvas_size_changed
        @canvas_size = _canvas_size
      end
    end

    def draw_cursor
      @cursor.draw(mouse_x, mouse_y, Float::INFINITY)
    end

    def update
      super

      @console.update if @show_console
      @overlay.update
      SoundManager.update
    end

    def close
      push_state(Close)
    end

    def button_down(id)
      if @show_console
        @console.button_down(id)
      elsif @input_hijacker
        @input_hijacker.button_down(id)
      else
        super
      end

      if id == Gosu::KbBacktick
        @show_console ? @console.blur : @console.focus && InputMapper.reset_keys
        @show_console = !@show_console
      end
    end

    def button_up(id)
      if @show_console
        @console.button_up(id)
      elsif @input_hijacker
        @input_hijacker.button_up(id)
      else
        super
      end
    end
  end
end
