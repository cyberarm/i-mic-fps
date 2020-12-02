# frozen_string_literal: true
class IMICFPS
  class Crosshair
    include CommonMethods

    def initialize(color: Gosu::Color.rgb(255,127,0), size: 10, thickness: 3)
      @color = color
      @size = size
      @thickness = thickness
    end

    def draw
      draw_rect(window.width/2-@size, (window.height/2-@size)-@thickness/2, @size*2, @thickness, @color, 0, :default)
      draw_rect((window.width/2)-@thickness/2, window.height/2-(@size*2), @thickness, @size*2, @color, 0, :default)
    end
  end
end