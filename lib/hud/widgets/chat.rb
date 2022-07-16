# frozen_string_literal: true

class IMICFPS
  class HUD
    class ChatWidget < HUD::Widget
      def setup
        @deliver_to_text = Text.new("", size: 28, font: BOLD_SANS_FONT)
        @text = Text.new("", size: 28, font: SANS_FONT)

        @text_input = nil
        @background = Gosu::Color.new(0x88c64600)
        @selection_color = Gosu::Color.new(0x88222222)
        @width = @options[:width] || 400

        @delivery_options = [:all, :team, :squad]
      end

      def draw
        return unless @text_input

        Gosu.draw_rect(
          Widget.horizontal_margin, CyberarmEngine::Window.instance.height / 2 - (@text.height / 2 + Widget.horizontal_padding),
          @width - Widget.horizontal_padding * 2, @text.height + Widget.vertical_padding * 2,
          @background
        )

        @deliver_to_text.draw

        clip_width = @deliver_to_text.width + Widget.horizontal_padding * 3 + Widget.horizontal_margin
        Gosu.clip_to(@text.x, @text.y, @width - clip_width, @text.height) do
          x = Widget.horizontal_margin + Widget.horizontal_padding + @deliver_to_text.width

          cursor_x = x + @text.width(@text_input.text[0...@text_input.caret_pos])
          selection_x = x + @text.width(@text_input.text[0...@text_input.selection_start])
          selection_width = cursor_x - selection_x
          cursor_thickness = 2

          Gosu.draw_rect(selection_x, @text.y, selection_width, @text.height, @selection_color)
          Gosu.draw_rect(cursor_x, @text.y, cursor_thickness, @text.height, Gosu::Color::WHITE)
          @text.draw
        end
      end

      def update
        @deliver_to_text.text = "#{@deliver_to}: "
        @deliver_to_text.x = Widget.horizontal_margin + Widget.horizontal_padding
        @deliver_to_text.y = CyberarmEngine::Window.instance.height / 2 - (@text.height / 2)

        @text.text = @text_input&.text.to_s
        @text.x = Widget.horizontal_margin + Widget.horizontal_padding + @deliver_to_text.width
        @text.y = CyberarmEngine::Window.instance.height / 2 - (@text.height / 2)
      end

      def button_down(id)
        # TODO: Use InputMapper keymap to function
        # NOTE: Account for Y in QWERTZ layout
        case id
        when Gosu::KB_T, Gosu::KB_Y, Gosu::KB_U
          return if @text_input

          hijack_input!

          @text_input = window.text_input = Gosu::TextInput.new

          @deliver_to = :all if Gosu.button_down?(Gosu::KbT)
          @deliver_to = :team if Gosu.button_down?(Gosu::KbY)
          @deliver_to = :squad if Gosu.button_down?(Gosu::KbU)
        when Gosu::KB_TAB
          return unless @text_input

          cycle_deliver_to
        end
      end

      def button_up(id)
        return unless @text_input

        case id
        when Gosu::KB_ENTER, Gosu::KB_RETURN
          release_input!

          # TODO: Deliver message to server

          @text_input = window.text_input = nil
        when Gosu::KB_ESCAPE
          release_input!
          @text_input = window.text_input = nil
        end
      end

      def cycle_deliver_to
        i = @delivery_options.index(@deliver_to)
        @deliver_to = @delivery_options[(i + 1) % (@delivery_options.size)]
      end
    end
  end
end
