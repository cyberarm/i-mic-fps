class IMICFPS
  class HUD
    class RadarWidget < HUD::Widget
      def setup
        @size = 288
        @border_color = Gosu::Color.new(0x88c64600)
        @radar_color = Gosu::Color.new(0x88212121)

        @text = Text.new("RADAR", size: 18, mode: :add, font: MONOSPACE_FONT)
        @image = Gosu::Image.new("#{CYBERARM_ENGINE_ROOT_PATH}/assets/textures/default.png", retro: true)
        @scale = (@size - @padding * 2.0) / @image.width
      end

      def draw
        Gosu.draw_rect(
          @margin, window.height - (@size + @margin),
          @size, @size,
          @border_color
        )

        Gosu.draw_rect(
          @margin + @padding, window.height - (@size + @margin) + @padding,
          @size - @padding * 2, @size - @padding * 2,
          @radar_color
        )
        
        @image.draw(@margin + @padding, window.height - (@size + @margin) + @padding, 46, @scale, @scale, 0x88ffffff)

        @text.draw
      end

      def update
        @text.text = "RADAR: X #{@player.position.x.round(1)} Y #{@player.position.y.round(1)} Z #{@player.position.z.round(1)}"
        @text.x = @margin + @size / 2 - @text.width / 2
        @text.y = window.height - (@margin + @size + @text.height)
      end
    end
  end
end
