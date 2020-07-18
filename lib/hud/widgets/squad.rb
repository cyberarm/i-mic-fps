class IMICFPS
  class HUD
    class SquadWidget < HUD::Widget
      def setup
        @size = 288 # RADAR size
        @color = Gosu::Color.new(0x8800aa00)

        @text = Text.new("MATE\nTinyTanker\nOther Player Dude\nHuman 0xdeadbeef", size: 18, mode: :add, font: MONOSPACE_FONT, color: @color)
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
