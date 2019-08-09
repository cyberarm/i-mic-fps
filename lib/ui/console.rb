class IMICFPS
  class Console
    Z = 100_000
    PADDING = 2
    include CommonMethods

    def initialize
      @text_input = Gosu::TextInput.new

      @input = Text.new("", x: 4, y: window.height / 4 * 3 - (PADDING * 2), z: Console::Z + 1)
      @input.y -= @input.height

      @history_height = window.height / 4 * 3 - (PADDING * 2 + @input.textobject.height)
      @history = Text.new("=== #{IMICFPS::NAME} v#{IMICFPS::VERSION} (#{IMICFPS::RELEASE_NAME}) ===\n\n", x: 4, y: @history_height, z: Console::Z + 1)
      update_history

      @command_history       = []
      @command_history_index = 0

      @background_color = Gosu::Color.rgba(0, 0, 0, 200)
      @foreground_color = Gosu::Color.rgba(100, 100, 100, 100)
      @input_color      = Gosu::Color.rgba(100, 100, 100, 200)

      @showing_cursor = false
      @active_text_input = nil

      @show_caret = true
      @caret_last_change = Gosu.milliseconds
      @caret_interval = 250
      @caret_color = Gosu::Color::WHITE

      @width  = window.width  / 4 * 3
      @height = window.height / 4 * 3
    end

    def draw
      # Background/Border
      draw_rect(0, 0, @width, @height, @background_color, Console::Z)
      # Foregound/History
      draw_rect(PADDING, PADDING, @width - (PADDING * 2), @height - (PADDING * 2), @foreground_color, Console::Z)
      # Text bar
      draw_rect(2, @input.y, @width - (PADDING * 2), @input.height, @input_color, Console::Z)

      @history.draw
      @input.draw
      # Caret
      draw_rect(@input.x + caret_pos, @input.y, Console::PADDING, @input.height, @caret_color, Console::Z + 2) if @show_caret
    end

    def caret_pos
      return 0 if @text_input.caret_pos == 0
      @input.textobject.text_width(@text_input.text[0..@text_input.caret_pos-1])
    end

    def update
      if Gosu.milliseconds - @caret_last_change >= @caret_interval
        @caret_last_change = Gosu.milliseconds
        @show_caret = !@show_caret
      end

      @input.text = @text_input.text
    end

    def button_down(id)
      case id
      when Gosu::KbEnter, Gosu::KbReturn
        return unless @text_input.text.length > 0
        @history.text += "\n<c=999999>> #{@text_input.text}</c>"
        @command_history << @text_input.text
        @command_history_index = @command_history.size
        update_history
        handle_command
        @text_input.text = ""

      when Gosu::KbUp
        @command_history_index -= 1
        @command_history_index = 0 if @command_history_index < 0
        @text_input.text = @command_history[@command_history_index]

      when Gosu::KbDown
        @command_history_index += 1
        if @command_history_index > @command_history.size - 1
          @command_history_index = @command_history.size - 1
          @text_input.text = ""
        else
          @text_input.text = @command_history[@command_history_index]
        end

      when Gosu::KbTab
        split = @text_input.text.split(" ")

        if !@text_input.text.end_with?(" ") && split.size == 1
          list = command_search(@text_input.text)

          if list.size == 1
            @text_input.text = "#{list.first} "
          else
            @history.text += "\n#{list.map { |cmd| Commands::Style.highlight(cmd)}.join(", ")}"
            update_history
          end
        else
          if split.size > 0 && cmd = Commands::Command.find(split.first)
            cmd.autocomplete(self)
          end
        end

      when Gosu::KbBacktick
        # Removed backtick character from input
        if @text_input.text.size > 1
          @text_input.text = @text_input.text[0..@text_input.text.size - 2]
        else
          @text_input.text = ""
        end
      end
    end

    def button_up(id)
    end

    def update_history
      @history.y = @history_height - (@history.text.lines.count * (@history.textobject.height))
    end

    def handle_command
      string = @text_input.text
      split  = string.split(" ")
      command = split.first
      arguments = split.length > 0 ? split[1..split.length - 1] : []

      IMICFPS::Commands::Command.use(command, arguments, self)
    end

    def command_search(text)
      return [] unless text.length > 0

      @command_search ||= Abbrev.abbrev(Commands::Command.list_commands.map { |cmd| cmd.command.to_s})

      list = []
      @command_search.each do |abbrev, value|
        next unless abbrev && abbrev.start_with?(text)

        list << value
      end

      return list.uniq
    end

    def stdin(string)
      @history.text += "\n#{string}"
      update_history
    end

    def focus
      @active_text_input = window.text_input
      window.text_input = @text_input

      @showing_cursor = window.show_cursor
      window.show_cursor = true

      @show_caret = true
      @caret_last_change = Gosu.milliseconds
    end

    def blur
      window.text_input  = @active_text_input
      window.show_cursor = @showing_cursor
    end
  end
end