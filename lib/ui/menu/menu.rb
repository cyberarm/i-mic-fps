class Menu
  def initialize
    @elements = []
    setup
  end

  def setup
  end

  def draw
    @elements.each(&:draw)
  end

  def update
    @elements.each(&:update)
  end

  def button(text, x:, y:, &block)
    @element << Button.new(text, x, y, block)
  end

  def label(text, x:, y:)
    @element << Text.new(text, x: x, y: y, size: 24)
  end

  class Button
    PADDING = 10
    def initialize(text, x, y, block)
      @text = Text.new(text, x: x, y: y)
    end

    def draw
      Gosu.draw_rect(x-PADDING, y-PADDING, @text.width+PADDING, @text.height+PADDING, Gosu::Color.rgb(0, 100, 0))
      @text.draw
    end

    def update
    end

    def mouse_over?
    end
  end
end
