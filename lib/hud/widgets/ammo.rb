# frozen_string_literal: true

class IMICFPS
  class HUD
    class AmmoWidget < HUD::Widget
      def setup
        @text = Text.new("", size: 64, font: MONOSPACE_FONT, border: true, border_color: Gosu::Color::BLACK)
        @background = Gosu::Color.new(0x88c64600)
      end

      def draw
        Gosu.draw_rect(
          @text.x - Widget.horizontal_padding, @text.y - Widget.vertical_padding,
          @text.width + Widget.horizontal_padding * 2, @text.height + Widget.vertical_padding * 2,
          @background
        )
        @text.draw
      end

      def update
        if (Gosu.milliseconds / 1000.0) % 1.0 >= 0.9
          random = rand(0..199).to_s.rjust(3, "0")
          @text.text = "#{random}/999"
        end

        @text.x = window.width - (Widget.horizontal_margin + @text.width + Widget.horizontal_padding)
        @text.y = window.height - (Widget.vertical_margin + @text.height + Widget.vertical_padding)
      end
    end
  end
end
