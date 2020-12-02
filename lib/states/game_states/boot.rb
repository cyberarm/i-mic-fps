# frozen_string_literal: true
class IMICFPS
  class Boot < GameState
    def setup
      @title = Text.new(IMICFPS::NAME, size: 100, z: 0, color: Gosu::Color.new(0xff000000), shadow: false, font: "Droid Serif")
      @logo = get_image(IMICFPS::GAME_ROOT_PATH + "/static/logo.png")

      @start_time = Gosu.milliseconds
      @time_to_live = 3_000

      # SoundManager.sound_effect(SoundEffect::FadeIn, sound: SoundManager.sound("base", :shield_regen), duration: 3_000.0)
      window.needs_cursor = false
    end

    def draw
      fraction_left = ((Gosu.milliseconds - @start_time) / (@time_to_live - 200).to_f)

      menu_background(Menu::PRIMARY_COLOR, Menu::ACCENT_COLOR, Menu::BAR_COLOR_STEP, Menu::BAR_ALPHA, Menu::BAR_SIZE, Menu::BAR_SLOPE)

      if fraction_left <= 1.0
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

        @title.draw

        fill(Gosu::Color.rgba(0,0,0, 255 * (1.2 - fraction_left)))
      end
    end

    def update
      @title.x = window.width / 2 - @title.width / 2
      @title.y = 0

      push_state(MainMenu) if Gosu.milliseconds - @start_time >= @time_to_live
    end

    def button_up(id)
      if id == Gosu::KbEscape or
        (id >= Gosu::GP_LEFT and id >= Gosu::GP_BUTTON_15) or
        id == Gosu::MsLeft
        push_state(MainMenu)
      end
    end
  end
end