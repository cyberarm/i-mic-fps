class IMICFPS
  class Menu < GameState
    def initialize
      @elements = []
      @size = 50
      @slope = 250
      @color_step = 10
      @base_color = Gosu::Color.rgb(255, 127, 0)
      super
    end

    def title(text, color = @base_color)
      @elements << Text.new(text, color: color, size: 100, x: 0, y: 15, alignment: :center)
    end

    def link(text, color = Gosu::Color.rgb(0,127,127), &block)
      text = Text.new(text, color: color, size: 50, x: 0, y: 100+(60*@elements.count), alignment: :center)
      @elements << Link.new(text, self, block)
    end

    def draw
      @background ||= Gosu.record(Gosu.screen_width, Gosu.screen_height) do
        ((Gosu.screen_height+@slope)/@size).times do |i|
          fill_quad(
            0, i*@size,
            0, @slope+(i*@size),
            $window.width/2, (-@slope)+(i*@size),
            $window.width/2, i*@size,
            Gosu::Color.rgba(@base_color.red-i*@color_step, @base_color.green-i*@color_step, @base_color.blue-i*@color_step, 200)
          )
          fill_quad(
            $window.width, i*@size,
            $window.width, @slope+(i*@size),
            $window.width/2, (-@slope)+(i*@size),
            $window.width/2, i*@size,
            Gosu::Color.rgba(@base_color.red-i*@color_step, @base_color.green-i*@color_step, @base_color.blue-i*@color_step, 200)
          )
        end
      end

      @background.draw(0, 0, 0)

      # Box
      draw_rect(
        $window.width/4, 0,
        $window.width/2, $window.height,
        Gosu::Color.rgba(100, 100, 100, 150)
        # Gosu::Color.rgba(@base_color.red+@color_step, @base_color.green+@color_step, @base_color.blue+@color_step, 200)
      )

      # Texts
      @elements.each do |e|
        e.draw
      end

      # Cursor
      fill_quad(
        mouse_x, mouse_y,
        mouse_x+16, mouse_y+16,
        mouse_x, mouse_y+16,
        mouse_x, mouse_y+16,
        Gosu::Color::RED, Float::INFINITY
      )
    end

    def update
      @elements.each do |e|
        e.update
      end
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
      close if id == Gosu::KbEscape
      if Gosu::MsLeft
        @elements.each do |e|
          next unless e.is_a?(Link)
          if mouse_over?(e)
            e.clicked
          end
        end
      end
    end

    def mouse_over?(object)
      if mouse_x.between?(object.x, object.x+object.width)
        if mouse_y.between?(object.y, object.y+object.height)
          true
        end
      end
    end

    class Link
      attr_reader :text, :block
      def initialize(text, host, block)
        @text, @host, @block = text, host, block
        @color = @text.color
        @hover_color = Gosu::Color.rgb(255, 127, 0)
      end

      def update
        if @host.mouse_over?(self)
          @text.color = @hover_color
        else
          @text.color = @color
        end
      end

      def x; text.x; end
      def y; text.y; end
      def width; text.width; end
      def height; text.height; end
      def draw; text.draw; end
      def clicked; @block.call; end
    end
  end
end