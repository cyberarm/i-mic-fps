class IMICFPS
  class HUD
    class AmmoWidget < HUD::Widget
      def setup
        @text = Text.new("", size: 64, mode: :add, font: MONOSPACE_FONT)
        @background = Gosu::Color.new(0x88c64600)
      end

      def draw
        Gosu.draw_rect(
          @text.x - Widget.padding, @text.y - Widget.padding,
          @text.width + Widget.padding * 2, @text.height + Widget.padding * 2,
          @background
        )
        @text.draw
      end

      def update
        if (Gosu.milliseconds / 1000.0) % 1.0 >= 0.9
          random = "#{rand(0..199)}".rjust(3, "0")
          @text.text = "#{random}/999"
        end

        @text.x = window.width - (Widget.margin + @text.width + Widget.padding)
        @text.y = window.height - (Widget.margin + @text.height + Widget.padding)
      end
    end
  end
end