class IMICFPS
  class HUD
    class AmmoWidget < HUD::Widget
      def setup
        @text = Text.new("")
        @background = Gosu::Color.new(0x88222222)
      end

      def draw
        Gosu.draw_rect(
          @text.x - @margin, @text.y - @margin,
          @text.width + @margin * 2, @text.height + @margin * 2,
          @background
        )
        @text.draw
      end

      def update
        if (Gosu.milliseconds / 1000.0) % 1.0 >= 0.9
          random = "#{rand(0..999)}".rjust(3, "0")
          @text.text = "Pistol\nAMMO: #{random}"
        end

        @text.x = window.width - (@margin * 2 + @text.width)
        @text.y = window.height - (@margin * 2 + @text.height)
      end
    end
  end
end