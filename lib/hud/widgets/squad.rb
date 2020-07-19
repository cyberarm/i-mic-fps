class IMICFPS
  class HUD
    class SquadWidget < HUD::Widget
      def setup
        @size = 288 # RADAR size
        @color = Gosu::Color.new(0xff00aa00)

        @text = Text.new(
          "MATE\nTinyTanker\nOther Player Dude\nHuman 0xdeadbeef",
          size: 18,
          mode: :add,
          font: SANS_SERIF_FONT,
          color: @color,
          shadow: true,
          shadow_color: 0x88000000,
          shadow_size: 0.75
        )
      end

      def draw
        @text.draw
      end

      def update
        @text.x = Widget.margin + @size + Widget.padding
        @text.y = window.height - (Widget.margin + @text.height)
      end
    end
  end
end
