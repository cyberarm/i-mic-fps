class IMICFPS
  class Menu < IMICFPS::GameState
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

      @__version_text = CyberarmEngine::Text.new("<b>#{IMICFPS::NAME}</b> v#{IMICFPS::VERSION} (#{IMICFPS::RELEASE_NAME})")
      @__version_text.x = window.width - (@__version_text.width + 10)
      @__version_text.y = window.height - (@__version_text.height + 10)
      super(*args)
    end

    def title(text, color = Gosu::Color::BLACK)
      @elements << Text.new(text, color: color, size: 100, x: 0, y: 15)
      @_title = @elements.last
    end

    def subtitle(text, color = Gosu::Color::WHITE)
      @elements << Text.new(text, color: color, size: 50, x: 0, y: 100)
      @_subtitle = @elements.last
    end

    def link(text, color = Gosu::Color.rgb(0,127,127), &block)
      text = Text.new(text, color: color, size: 50, x: 0, y: 100 + (60 * @elements.count))
      @elements << Link.new(text, self, block)
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
    end

    def draw_menu_box
      draw_rect(
        window.width/4, 0,
        window.width/2, window.height,
        Gosu::Color.new(0x22222222),
      )
    end

    def draw_menu
      @elements.each do |e|
        e.draw
      end
    end

    def update
      @elements.each do |e|
        e.x = (window.width / 2 - e.width / 2).round
        e.update
      end

      if window.scene
        window.scene.update(window.dt)
      end

      @__version_text.x = window.width - (@__version_text.width + 10)
      @__version_text.y = window.height - (@__version_text.height + 10)
    end

    def button_up(id)
      if id == Gosu::MsLeft
        @elements.each do |e|
          next unless e.is_a?(Link)
          if mouse_over?(e)
            e.clicked
          end
        end
      end
    end

    def mouse_over?(object)
      mouse_x.between?(object.x, object.x+object.width) &&
      mouse_y.between?(object.y, object.y+object.height)
    end

    class Link
      attr_reader :text, :block
      def initialize(text, host, block)
        @text, @host, @block = text, host, block
        @color = @text.color
        @hover_color = Gosu::Color.rgb(64, 128, 255)
        @text.shadow_color= Gosu::Color::BLACK
        @text.shadow_size = 2
        @text.shadow_alpha = 100
      end

      def update
        if @host.mouse_over?(self)
          @text.color = @hover_color
        else
          @text.color = @color
        end
      end

      def x; text.x; end
      def x=(n); text.x = n; end
      def y; text.y; end
      def width; text.width; end
      def height; text.height; end
      def draw; text.draw; end
      def clicked; @block.call if @block; end
    end
  end
end
