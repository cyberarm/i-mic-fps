# frozen_string_literal: true

class IMICFPS
  class HUD
    class RadarWidget < HUD::Widget
      def setup
        @min_size = 148
        @max_size = 288
        @target_screen_width = 1920
        @size = @max_size

        @border_color = Gosu::Color.new(0x88c64600)
        @radar_color = Gosu::Color.new(0x88212121)

        @text = Text.new("RADAR", size: 18, font: MONOSPACE_FONT, border: true, border_color: Gosu::Color::BLACK)
        @image = Gosu::Image.new("#{CYBERARM_ENGINE_ROOT_PATH}/assets/textures/default.png", retro: true)
        @scale = (@size - Widget.horizontal_padding * 2.0) / @image.width
      end

      def draw
        Gosu.draw_rect(
          Widget.horizontal_margin, window.height - (@size + Widget.vertical_margin),
          @size, @size,
          @border_color
        )

        Gosu.draw_rect(
          Widget.horizontal_margin + Widget.horizontal_padding,
          window.height - (@size + Widget.vertical_margin) + Widget.vertical_padding,
          @size - Widget.horizontal_padding * 2, @size - Widget.horizontal_padding * 2,
          @radar_color
        )

        @image.draw(
          Widget.horizontal_margin + Widget.horizontal_padding,
          window.height - (@size + Widget.vertical_margin) + Widget.vertical_padding,
          46, @scale, @scale, 0x88ffffff
        )

        @text.draw
      end

      def update
        @size = (window.width / @target_screen_width.to_f * @max_size).clamp(@min_size, @max_size)
        @scale = (@size - Widget.horizontal_padding * 2.0) / @image.width

        @text.text = "X: #{@player.position.x.round(1)} Y: #{@player.position.y.round(1)} Z: #{@player.position.z.round(1)}"
        @text.x = Widget.horizontal_margin + @size / 2 - @text.width / 2
        @text.y = window.height - (Widget.vertical_margin + @size + @text.height)
      end
    end
  end
end
