class IMICFPS
  class HUD
    class HealthWidget < HUD::Widget
      def setup
        @spacer = 0
        @text = Text.new("", mode: :add, font: MONOSPACE_FONT)
        @width = 512
        @height = 24
        @slant = 32

        @color = Gosu::Color.new(0x66ffa348)
        @shield = Gosu::Color.new(0xaae66100)

        @health = 0.0
      end

      def draw
        @text.draw
        fill_quad(
          window.width / 2 - @width / 2, @spacer + Widget.margin, # TOP LEFT
          window.width / 2 + @width / 2, @spacer + Widget.margin, # TOP RIGHT
          window.width / 2 + @width / 2 - @slant, @spacer + Widget.margin + @height, # BOTTOM RIGHT
          window.width / 2 - @width / 2 + @slant, @spacer + Widget.margin + @height, # BOTTOM LEFT
          @color
        )

        bottom_right = (window.width / 2 - @width / 2) + @width * @health - @slant
        if @width * @health - @slant < @slant
          bottom_right = (window.width / 2 - @width / 2) + @slant
        end

        # Current Health
        fill_quad(
          window.width / 2 - @width / 2, @spacer + Widget.margin, # TOP LEFT
          (window.width / 2 - @width / 2) + @width * @health, @spacer + Widget.margin, # TOP RIGHT
          bottom_right, @spacer + Widget.margin + @height, # BOTTOM RIGHT
          window.width / 2 - @width / 2 + @slant, @spacer + Widget.margin + @height, # BOTTOM LEFT
          @shield
        )
      end

      def update
        percentage = "#{(@health * 100).round}".rjust(3, "0")
        @text.text = "[Health #{percentage}%]"
        @text.x = window.width / 2 - @text.width / 2
        @text.y = @spacer + Widget.margin + @height / 2 - @text.height / 2

        @health += 0.1 * window.dt
        @health = 0 if @health > 1.0
      end
    end
  end
end