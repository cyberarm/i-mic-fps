class IMICFPS
  class HUD
    class AmmoWidget < HUD::Widget
      def setup
        @text = Text.new("", size: 64, mode: :add, font: MONOSPACE_FONT)
        @background = Gosu::Color.new(0x88c64600)
      end

      def draw
        Gosu.draw_rect(
          @text.x - @padding, @text.y - @padding,
          @text.width + @padding * 2, @text.height + @padding * 2,
          @background
        )
        @text.draw
      end

      def update
        if (Gosu.milliseconds / 1000.0) % 1.0 >= 0.9
          random = "#{rand(0..199)}".rjust(3, "0")
          @text.text = "#{random}/999"
        end

        @text.x = window.width - (@margin + @text.width + @padding)
        @text.y = window.height - (@margin + @text.height + @padding)
      end
    end
  end
end