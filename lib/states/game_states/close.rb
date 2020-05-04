class IMICFPS
  class Close < GameState
    def setup
      @primary_color = Gosu::Color.rgba(255, 127, 0, 200)
      @accent_color = Gosu::Color.rgba(155, 27, 0, 200)

      @color_step = 10
      @transparency = 200
      @bar_size = 50
      @slope = 250

      @logo = get_image(IMICFPS::GAME_ROOT_PATH + "/static/logo.png")

      @start_time = Gosu.milliseconds
      @time_to_live = 3_000

      window.needs_cursor = false
    end

    def draw
      menu_background(@primary_color, @color_step, @transparency, @bar_size, @slope.round)

      fraction_left = 1 - ((Gosu.milliseconds - @start_time) / (@time_to_live - 200).to_f)

      Gosu.draw_quad(
        0, 0, @primary_color,
        window.width, 0, @primary_color,
        window.width, window.height, @accent_color,
        0, window.height, @accent_color
      )

      Gosu.draw_circle(
        window.width / 2,
        window.height / 2,
        @logo.width / 2, 128, Gosu::Color.new(0x11ffffff)
      )

      Gosu.draw_arc(
        window.width / 2,
        window.height / 2,
        @logo.width / 2, fraction_left.clamp(0.0, 1.0), 128, 8, Gosu::Color.new(0x33ff8800)
      )

      @logo.draw(window.width / 2 - @logo.width / 2, window.height / 2 - @logo.height / 2, 0)

      fill(Gosu::Color.rgba(0,0,0, 255 * (1.1 - fraction_left)))
    end

    def update
      window.close! if Gosu.milliseconds - @start_time >= @time_to_live
      @slope -= 25 * window.dt
    end

    def button_up(id)
      if id == Gosu::KbEscape or
        (id >= Gosu::GP_LEFT and id >= Gosu::GP_BUTTON_15) or
        id == Gosu::MsLeft
        window.close!
      end
    end
  end
end