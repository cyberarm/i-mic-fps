class IMICFPS
  class Boot < GameState
    require_relative "../../../../gosu_more_drawables/lib/gosu_more_drawables/draw_circle"

    def setup
      @primary_color = Gosu::Color.rgba(255, 127, 0, 200)
      @accent_color = Gosu::Color.rgba(155, 27, 0, 200)

      @title = Text.new(IMICFPS::NAME, size: 100, z: 0, color: Gosu::Color.new(0xff000000), shadow: false, font: "Droid Serif")
      @logo = get_image(IMICFPS::GAME_ROOT_PATH + "/static/logo.png")

      @start_time = Gosu.milliseconds
      @time_to_live = 3_000
    end

    def draw
      menu_background(@primary_color, 10, 200, 50, 250)

      fraction_left = ((Gosu.milliseconds - @start_time) / (@time_to_live - 200).to_f)

      Gosu.draw_quad(
        0, 0, @primary_color,
        window.width, 0, @primary_color,
        window.width, window.height, @accent_color,
        0, window.height, @accent_color
      )

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

      end
    end

    def update
      @title.x = window.width / 2 - @title.width / 2
      @title.y = 0

      push_state(MainMenu) if Gosu.milliseconds - @start_time >= @time_to_live
    end

    def button_up(id)
      push_state(MainMenu)
    end
  end
end