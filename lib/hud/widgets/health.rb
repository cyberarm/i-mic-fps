class IMICFPS
  class HUD
    class HealthWidget < HUD::Widget
      def setup
        @spacer = 0
        @text = Text.new("")
        @width = 512
        @height = 24
        @slant = 32

        @color = Gosu::Color.rgba(100, 100, 200, 128)
        @shield = Gosu::Color.rgba(200, 100, 50, 200)

        @health = 0.0
      end

      def draw
        @text.draw
        fill_quad(
          window.width / 2 - @width / 2, @spacer, # TOP LEFT
          window.width / 2 + @width / 2, @spacer, # TOP RIGHT
          window.width / 2 + @width / 2 - @slant, @spacer + @height, # BOTTOM RIGHT
          window.width / 2 - @width / 2 + @slant, @spacer + @height, # BOTTOM LEFT
          @color
        )

        # Current Health
        fill_quad(
          window.width / 2 - @width / 2, @spacer, # TOP LEFT
          (window.width / 2 - @width / 2) + @width * @health, @spacer, # TOP RIGHT
          (window.width / 2 - @width / 2) + @width * @health - @slant, @spacer + @height, # BOTTOM RIGHT
          window.width / 2 - @width / 2 + @slant, @spacer + @height, # BOTTOM LEFT
          @shield
        )
      end

      def update
        percentage = "#{(@health * 100).round}".rjust(3, "0")
        @text.text = "[Health #{percentage}%]"
        @text.x = window.width / 2 - @text.width / 2
        @text.y = @spacer + @height / 2 - @text.height / 2

        @health += 0.1 * window.dt
        @health = 0 if @health > 1.0
      end
    end
  end
end