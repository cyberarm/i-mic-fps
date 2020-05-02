class IMICFPS
  class Overlay
    include CommonMethods
    def initialize
      @text = CyberarmEngine::Text.new("")
    end

    def draw
      Gosu.draw_rect(0, 0, 256, 20, Gosu::Color.rgba(0, 0, 0, 100))
      Gosu.draw_rect(2, 2, 256 - 4, 20 - 4, Gosu::Color.rgba(100, 100, 100, 100))
      @text.x = 3
      @text.y = 3
      @text.text = "FPS: #{Gosu.fps}"
      @text.draw
    end
  end
end