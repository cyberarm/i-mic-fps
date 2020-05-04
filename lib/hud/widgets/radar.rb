class IMICFPS
  class HUD
    class RadarWidget < HUD::Widget
      def setup
        @size = 256
        @color = Gosu::Color.new(0x88222222)

        @text = Text.new("RADAR")
      end

      def draw
        Gosu.draw_rect(
          @margin, window.height - (@size + @margin),
          @size, @size,
          @color
        )

        @text.draw
      end

      def update
        @text.text = "RADAR: X #{@player.position.x.round(1)} Y #{@player.position.z.round(1)}"
        @text.x = @margin + @size / 2 - @text.width / 2
        @text.y = window.height - (@margin + @size)
      end
    end
  end
end