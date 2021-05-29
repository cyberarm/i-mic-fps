# frozen_string_literal: true

class IMICFPS
  class HUD
    class SquadWidget < HUD::Widget
      def setup
        @min_size = 148
        @max_size = 288 # RADAR size
        @target_screen_width = 1920
        @size = @max_size

        @color = Gosu::Color.new(0xff00aa00)

        @text = Text.new(
          "MATE\nTinyTanker\nOther Player Dude\nHuman 0xdeadbeef",
          size: 18,
          font: SANS_FONT,
          color: @color,
          border: true,
          border_color: Gosu::Color::BLACK,
        )
      end

      def draw
        @text.draw
      end

      def update
        @size = (window.width / @target_screen_width.to_f * @max_size).clamp(@min_size, @max_size)

        @text.x = Widget.margin + @size + Widget.padding
        @text.y = window.height - (Widget.margin + @text.height)
      end
    end
  end
end
