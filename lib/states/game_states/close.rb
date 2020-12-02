# frozen_string_literal: true
class IMICFPS
  class Close < GameState
    def setup
      @slope = Menu::BAR_SLOPE

      @logo = get_image(IMICFPS::GAME_ROOT_PATH + "/static/logo.png")

      @start_time = Gosu.milliseconds
      @time_to_live = 3_000

      window.needs_cursor = false
    end

    def draw
      fraction_left = 1 - ((Gosu.milliseconds - @start_time) / (@time_to_live - 200).to_f)

      menu_background(Menu::PRIMARY_COLOR, Menu::ACCENT_COLOR, Menu::BAR_COLOR_STEP, Menu::BAR_ALPHA, Menu::BAR_SIZE, @slope.round)

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