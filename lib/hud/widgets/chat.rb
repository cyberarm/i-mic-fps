# frozen_string_literal: true

class IMICFPS
  class HUD
    class ChatWidget < HUD::Widget
      def setup
        @text = Text.new("", size: 28, font: SANS_FONT)
        @background = Gosu::Color.new(0x88c64600)
      end

      def draw
        return unless window.text_input

        Gosu.draw_rect(
          @text.x - Widget.padding, @text.y - Widget.padding,
          @text.width + Widget.padding * 2, @text.height + Widget.padding * 2,
          @background
        )

        @text.draw
      end

      def update
        # NOTE: Account for Y in QWERTZ layout
        text = window.text_input&.text

        if window.text_input.nil? && (Gosu.button_down?(Gosu::KbT) || Gosu.button_down?(Gosu::KbY) || Gosu.button_down?(Gosu::KbU))
          window.text_input = Gosu::TextInput.new

          @deliver_to = :all if Gosu.button_down?(Gosu::KbT)
          @deliver_to = :team if Gosu.button_down?(Gosu::KbY)
          @deliver_to = :squad if Gosu.button_down?(Gosu::KbU)
        end

        if window.text_input && (Gosu.button_down?(Gosu::KbEnter) || Gosu.button_down?(Gosu::KbReturn))
          window.text_input = nil
        end

        @text.text = text.to_s
        @text.x = window.width / 2 - (Widget.margin + @text.width / 2 + Widget.padding)
        @text.y = window.height - (Widget.margin + @text.height + Widget.padding)
      end
    end
  end
end
