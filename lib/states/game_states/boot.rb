# frozen_string_literal: true

class IMICFPS
  class Boot < GameState
    def setup
      @title = Text.new(IMICFPS::NAME, size: 100, z: 0, color: Gosu::Color.new(0xff000000), border: false, font: IMICFPS::BOLD_SANS_FONT)
      @logo = get_image("#{IMICFPS::GAME_ROOT_PATH}/static/logo.png")

      @start_time = Gosu.milliseconds
      @time_to_live = 5_000

      timing = Gosu.milliseconds
      @animators = [
        @fade_animator  = CyberarmEngine::Animator.new(
          start_time: timing,
          duration: 500,
          from: 0.0,
          to: 1.0,
          tween: :ease_in_out
        ),
        @logo_animator  = CyberarmEngine::Animator.new(
          start_time: timing += 500,
          duration: 500,
          from: 0.0,
          to: 1.0,
          tween: :swing_to#:bounce_past
        ),
        @title_animator = CyberarmEngine::Animator.new(
          start_time: timing += 1_000,
          duration: 500,
          from: 0.0,
          to: 1.0,
          tween: :swing_to#:ease_out_circ
        ),
        @arc_animator   = CyberarmEngine::Animator.new(
          start_time: timing += 500,
          duration: 2_500,
          from: 0.0,
          to: 1.0,
          tween: :ease_in_out
        )
      ]

      # SoundManager.sound_effect(SoundEffect::FadeIn, sound: SoundManager.sound("base", :shield_regen), duration: 3_000.0)
      window.needs_cursor = false
    end

    def draw
      fraction_left = ((Gosu.milliseconds - @start_time) / (@time_to_live - 200).to_f)

      menu_background(Menu::PRIMARY_COLOR, Menu::ACCENT_COLOR, Menu::BAR_COLOR_STEP, Menu::BAR_ALPHA, Menu::BAR_SIZE, Menu::BAR_SLOPE)

      if fraction_left <= 1.0
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

        @title.draw

        fill(Gosu::Color.rgba(0, 0, 0, 255 * (1 - @fade_animator.transition)))
      end
    end

    def update
      @animators.each(&:update)

      y = window.height / 2 - (@logo.height / 2 + @title.height + 8)
      y = 0 if y < @title.height

      @title.x = window.width / 2 - @title.width / 2
      @title.y = (0 - (@title.height * (1 - @title_animator.transition))) + (y * @title_animator.transition)

      push_state(MainMenu) if Gosu.milliseconds - @start_time >= @time_to_live
    end

    def button_down(id)
      super

      if (id == Gosu::KbEscape) ||
         ((id >= Gosu::GP_LEFT) && (id >= Gosu::GP_BUTTON_15)) ||
         (id == Gosu::MsLeft)
        push_state(MainMenu)
      end
    end
  end
end
