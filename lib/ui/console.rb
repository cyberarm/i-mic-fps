class IMICFPS
  class Console
    Z = 100_000
    PADDING = 2
    include CommonMethods

    attr_reader :text_input
    def initialize
      @text_input = Gosu::TextInput.new
      @width  = window.width  / 4 * 3
      @height = window.height / 4 * 3

      @input = Text.new("", x: 4, y: @height - (PADDING * 2), z: Console::Z + 1)
      @input.y -= @input.height

      @history = Text.new("=== #{IMICFPS::NAME} v#{IMICFPS::VERSION} (#{IMICFPS::RELEASE_NAME}) ===\n\n", x: 4, z: Console::Z + 1)
      update_history_y

      @command_history       = []
      @command_history_index = 0

      @memory = ""

      @background_color = Gosu::Color.rgba(0, 0, 0, 200)
      @foreground_color = Gosu::Color.rgba(100, 100, 100, 100)
      @input_color      = Gosu::Color.rgba(100, 100, 100, 200)

      @showing_cursor = false
      @active_text_input = nil

      @show_caret = true
      @caret_last_change = Gosu.milliseconds
      @caret_interval = 250
      @caret_color = Gosu::Color::WHITE
      @selection_color = Gosu::Color.new(0x5522ff22)
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
      draw_rect(@input.x + caret_from_left, @input.y, Console::PADDING, @input.height, @caret_color, Console::Z + 2) if @show_caret
      # Caret selection
      if caret_start != caret_end
        if caret_start < @text_input.selection_start
          draw_rect(@input.x + caret_from_left, @input.y, caret_selection_width, @input.height, @selection_color, Console::Z)
        else
          draw_rect((@input.x + caret_from_left) - caret_selection_width, @input.y, caret_selection_width, @input.height, @selection_color, Console::Z)
        end
      end
    end

    def caret_from_left
      return 0 if @text_input.caret_pos == 0
      @input.textobject.text_width(@text_input.text[0..@text_input.caret_pos-1])
    end

    def caret_selection_width
      @input.textobject.text_width(@text_input.text[caret_start..(caret_end - 1)])
    end

    def caret_pos
      @text_input.caret_pos
    end

    def caret_start
      @text_input.selection_start < @text_input.caret_pos ? @text_input.selection_start : @text_input.caret_pos
    end

    def caret_end
      @text_input.selection_start > @text_input.caret_pos ? @text_input.selection_start : @text_input.caret_pos
    end

    def update
      if Gosu.milliseconds - @caret_last_change >= @caret_interval
        @caret_last_change = Gosu.milliseconds
        @show_caret = !@show_caret
      end

      if @width != window.width || @height != @height
        @width  = window.width  / 4 * 3
        @height = window.height / 4 * 3

        @input.y = @height - (PADDING * 2 + @input.height)
        update_history_y
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
        update_history_y
        handle_command
        @text_input.text = ""

      when Gosu::KbUp
        @command_history_index -= 1
        @command_history_index = 0 if @command_history_index < 0
        @text_input.text = @command_history[@command_history_index]

      when Gosu::KbDown
        @command_history_index += 1
        if @command_history_index > @command_history.size - 1
          @text_input.text = "" unless @command_history_index > @command_history.size
          @command_history_index = @command_history.size
        else
          @text_input.text = @command_history[@command_history_index]
        end

      when Gosu::KbTab
        split = @text_input.text.split(" ")

        if !@text_input.text.end_with?(" ") && split.size == 1
          list = abbrev_search(Commands::Command.list_commands.map { |cmd| cmd.command.to_s}, @text_input.text)

          if list.size == 1
            @text_input.text = "#{list.first} "
          else
            stdin("\n#{list.map { |cmd| Commands::Style.highlight(cmd)}.join(", ")}") if list.size > 0
          end
        else
          if split.size > 0 && cmd = Commands::Command.find(split.first)
            cmd.autocomplete(self)
          end
        end

      when Gosu::KbBacktick
        # Remove backtick character from input
        if @text_input.text.size > 1
          @text_input.text = @text_input.text[0..@text_input.text.size - 2]
        else
          @text_input.text = ""
        end

      # Copy
      when Gosu::KbC
        if control_down? && shift_down?
          @memory = @text_input.text[caret_start..caret_end - 1] if caret_start != caret_end
          p @memory
        elsif control_down?
          @text_input.text = ""
        end

      # Paste
      when Gosu::KbV
        if control_down? && shift_down?
          string = @text_input.text.chars.insert(caret_pos, @memory).join
          _caret_pos = caret_pos
          @text_input.text = string
          @text_input.caret_pos = _caret_pos + @memory.length
          @text_input.selection_start = _caret_pos + @memory.length
        end

      # Cut
      when Gosu::KbX
        if control_down? && shift_down?
          @memory = @text_input.text[caret_start..caret_end - 1] if caret_start != caret_end
          string  = @text_input.text.chars
          Array(caret_start..caret_end - 1).each_with_index do |i, j|
            string.delete_at(i - j)
          end

          @text_input.text = string.join
        end

      # Delete word to left of caret
      when Gosu::KbW
        if control_down?
          split = @text_input.text.split(" ")
          split.delete(split.last)
          @text_input.text = split.join(" ")
        end

      # Clear history
      when Gosu::KbL
        if control_down?
          @history.text = ""
        end
      end
    end

    def button_up(id)
    end

    def update_history_y
      @history.y = @height - (PADDING * 2) - @input.height - (@history.text.lines.count * (@history.textobject.height))
    end

    def handle_command
      string = @text_input.text
      split  = string.split(" ")
      command = split.first
      arguments = split.length > 0 ? split[1..split.length - 1] : []

      IMICFPS::Commands::Command.use(command, arguments, self)
    end

    def abbrev_search(array, text)
      return [] unless text.length > 0

      list = []
      Abbrev.abbrev(array).each do |abbrev, value|
        next unless abbrev && abbrev.start_with?(text)

        list << value
      end

      return list.uniq
    end

    def stdin(string)
      @history.text += "\n#{string}"
      update_history_y
    end

    def focus
      InputMapper.reset_keys

      @active_text_input = window.text_input
      window.text_input = @text_input

      @showing_cursor = window.needs_cursor
      window.needs_cursor = true

      @show_caret = true
      @caret_last_change = Gosu.milliseconds
    end

    def blur
      window.text_input  = @active_text_input
      window.needs_cursor = @showing_cursor
    end
  end
end