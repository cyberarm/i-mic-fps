class IMICFPS
  class HUD
    class CrosshairWidget < HUD::Widget
      def setup
        @scale = 0.75
        @color = Gosu::Color.new(0x44ffffff)

        @image = Gosu::Image.new("#{GAME_ROOT_PATH}/static/crosshairs/crosshair.png")
        
        @last_changed_time = Gosu.milliseconds
        @change_interval = 1_500
        
        @colors = [0xffffffff, 0xaaffffff, 0x88ffffff, 0x22ffffff]
      end

      def draw
        @image.draw(
          window.width / 2 - (@image.width * @scale) / 2,
          window.height / 2 - (@image.height * @scale) / 2,
          46,
          @scale,
          @scale,
          @color
        )
      end

      def update
        if Gosu.milliseconds - @last_changed_time >= @change_interval
          @last_changed_time = Gosu.milliseconds

          @color = @colors.sample
        end
      end
    end
  end
end
