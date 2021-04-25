# frozen_string_literal: true

class IMICFPS
  class Close < GameState
    def setup
      @logo = get_image("#{IMICFPS::GAME_ROOT_PATH}/static/logo.png")

      @start_time = Gosu.milliseconds
      @time_to_live = 3_750

      timing = Gosu.milliseconds
      @animators = [
        @arc_animator   = CyberarmEngine::Animator.new(
          start_time: timing += 0,
          duration: 2_500,
          from: 1.0,
          to: 0.0,
          tween: :ease_in_out
        ),
        @logo_animator  = CyberarmEngine::Animator.new(
          start_time: timing += 2_500,
          duration: 500,
          from: 1.0,
          to: 0.0,
          tween: :swing_from
        ),
        @fade_animator  = CyberarmEngine::Animator.new(
          start_time: timing += 500,
          duration: 500,
          from: 0.0,
          to: 1.0,
          tween: :ease_in_out
        ),
      ]

      window.needs_cursor = false
    end

    def draw
      menu_background(Menu::PRIMARY_COLOR, Menu::ACCENT_COLOR, Menu::BAR_COLOR_STEP, Menu::BAR_ALPHA, Menu::BAR_SIZE, Menu::BAR_SLOPE)

      Gosu.scale(@logo_animator.transition, @logo_animator.transition, window.width / 2, window.height / 2) do
        Gosu.draw_circle(
          window.width / 2,
          window.height / 2,
          @logo.width / 2, 128, Gosu::Color.new(0x11ffffff)
        )

        Gosu.draw_arc(
          window.width / 2,
          window.height / 2,
          @logo.width / 2, @arc_animator.transition, 128, 8, Gosu::Color.new(0x33ff8800)
        )

        @logo.draw(window.width / 2 - @logo.width / 2, window.height / 2 - @logo.height / 2, 0)
      end

      fill(Gosu::Color.rgba(0, 0, 0, 255 * @fade_animator.transition))
    end

    def update
      window.close! if Gosu.milliseconds - @start_time >= @time_to_live
    end

    def button_up(id)
      if (id == Gosu::KbEscape) ||
         ((id >= Gosu::GP_LEFT) && (id >= Gosu::GP_BUTTON_15)) ||
         (id == Gosu::MsLeft)
        window.close!
      end
    end
  end
end
