# frozen_string_literal: true

class IMICFPS
  class Menu < IMICFPS::GuiState
    include CommonMethods

    PRIMARY_COLOR = Gosu::Color.rgba(255, 127, 0, 200)
    ACCENT_COLOR = Gosu::Color.rgba(155, 27, 0, 200)

    BAR_SIZE = 50
    BAR_SLOPE = 250
    BAR_COLOR_STEP = 10
    BAR_ALPHA = 200

    def initialize(*args)
      @elements = []
      @bar_size = BAR_SIZE
      @bar_slope = BAR_SLOPE
      @bar_color_step = BAR_COLOR_STEP
      @bar_alpha = BAR_ALPHA
      @primary_color = PRIMARY_COLOR
      @accent_color = ACCENT_COLOR
      window.needs_cursor = true

      @__version_text = CyberarmEngine::Text.new("<b>#{IMICFPS::NAME}</b> v#{IMICFPS::VERSION} (#{IMICFPS::RELEASE_NAME})", font: BOLD_SANS_FONT)
      @__version_text.x = window.width - (@__version_text.width + 10)
      @__version_text.y = window.height - (@__version_text.height + 10)

      super(*args)

      theme(
        {
          TextBlock:
          {
            font: SANS_FONT
          },
          Title: {
            font: BOLD_SANS_FONT,
            text_size: 100,
            color: Gosu::Color::BLACK,
            text_align: :center,
            width: 1.0
          },
          Subtitle: {
            text_size: 50,
            color: Gosu::Color::WHITE,
            text_align: :center,
            width: 1.0
          },
          Link: {
            font: BOLD_SANS_FONT,
            text_size: 50,
            text_align: :center,
            text_shadow: true,
            text_shadow_size: 2,
            text_shadow_color: Gosu::Color::BLACK,
            text_shadow_alpha: 100,
            color: Gosu::Color.rgb(0, 127, 127),
            width: 1.0,
            hover: {
              color: Gosu::Color.rgb(64, 128, 255),
              border_thickness: 2,
              border_color: Gosu::Color::BLACK,
            },
            active: {
              color: Gosu::Color.rgb(64, 128, 255),
            }
          },
          Button:
          {
            font: BOLD_SANS_FONT,
            background: [0xff222222, 0xff3A3A3E],
            border_color: [0xaa_111111, 0xaa_000000],
            border_thickness: 2,
            text_align: :center,
            # color: 0xffff8800,
            color: 0xffffffff,

            hover: {
              background: [0xff444444, 0xff5A5A5E],
              color: 0xffeeeeee
            },

            active: {
              color: Gosu::Color::WHITE,
              background: [0xff222222, 0xff1A1A1E]
            }
          }
        }
      )
    end

    def draw
      menu_background(@primary_color, @accent_color, @bar_color_step, @bar_alpha, @bar_size, @bar_slope)
      draw_menu_box
      draw_menu

      @__version_text.draw

      if window.scene
        window.gl(-1) do
          window.renderer.draw(window.scene.camera, window.scene.lights, window.scene.entities)
        end

        window.scene.draw
      end

      super
    end

    def draw_menu_box
      draw_rect(
        window.width / 4, 0,
        window.width / 2, window.height,
        Gosu::Color.new(0x11ffffff)
      )
    end

    def draw_menu
      @elements.each(&:draw)
    end

    def update
      @elements.each do |e|
        e.x = (window.width / 2 - e.width / 2).round
        e.update
      end

      window.scene&.update(window.dt)

      super

      @__version_text.x = window.width - (@__version_text.width + 10)
      @__version_text.y = window.height - (@__version_text.height + 10)
    end

    def button_up(id)
      if id == Gosu::MsLeft
        @elements.each do |e|
          next unless e.is_a?(Link)

          e.clicked if mouse_over?(e)
        end
      end

      super
    end

    def mouse_over?(object)
      mouse_x.between?(object.x, object.x + object.width) &&
        mouse_y.between?(object.y, object.y + object.height)
    end
  end
end
