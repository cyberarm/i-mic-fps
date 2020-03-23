class IMICFPS
  class Menu < IMICFPS::GameState
    def initialize(*args)
      @elements = []
      @size = 50
      @slope = 250
      @color_step = 10
      @base_color = Gosu::Color.rgb(255, 127, 0)
      @background_alpha = 200
      window.needs_cursor = true

      @__version_text = CyberarmEngine::Text.new("<b>#{IMICFPS::NAME}</b> v#{IMICFPS::VERSION} (#{IMICFPS::RELEASE_NAME})")
      @__version_text.x = window.width - (@__version_text.width + 10)
      @__version_text.y = window.height - (@__version_text.height + 10)
      super(*args)
    end

    def title(text, color = @base_color)
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
      draw_background
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

    def draw_background
      ((Gosu.screen_height+@slope)/@size).times do |i|
        fill_quad(
          0, i*@size,
          0, @slope+(i*@size),
          window.width/2, (-@slope)+(i*@size),
          window.width/2, i*@size,
          Gosu::Color.rgba(@base_color.red-i*@color_step, @base_color.green-i*@color_step, @base_color.blue-i*@color_step, @background_alpha),
          -2
        )
        fill_quad(
          window.width, i*@size,
          window.width, @slope+(i*@size),
          window.width/2, (-@slope)+(i*@size),
          window.width/2, i*@size,
          Gosu::Color.rgba(@base_color.red-i*@color_step, @base_color.green-i*@color_step, @base_color.blue-i*@color_step, @background_alpha),
          -2
        )
      end
    end

    def draw_menu_box
      draw_rect(
        window.width/4, 0,
        window.width/2, window.height,
        Gosu::Color.rgba(0, 0, 0, 150),
      )
    end

    def draw_menu
      @elements.each do |e|
        e.draw
      end
    end

    def update
      @elements.each do |e|
        e.x = window.width / 2 - e.width / 2
        e.update
      end

      if window.scene
        window.scene.update(window.dt)
      end

      @__version_text.x = window.width - (@__version_text.width + 10)
      @__version_text.y = window.height - (@__version_text.height + 10)
    end

    def fill_quad(x1, y1, x2, y2, x3, y3, x4, y4, color = Gosu::Color::WHITE, z = 0, mode = :default)
      draw_quad(
        x1,y1, color,
        x2,y2, color,
        x3,y3, color,
        x4,y4, color,
        z, mode
        )
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
        @hover_color = Gosu::Color.rgb(64, 127, 255)
        @text.shadow_alpha = 100
      end

      def update
        if @host.mouse_over?(self)
          @text.color = @hover_color
          @text.shadow_color= Gosu::Color::BLACK
          @text.shadow_size = 3
        else
          @text.color = @color
          @text.shadow_color = nil
          @text.shadow_size = 1
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
