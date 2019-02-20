class IMICFPS
  class Vector

    attr_accessor :x, :y, :z, :weight
    def initialize(x = 0, y = 0, z = 0, weight = 0)
      @x, @y, @z, @weight = x, y, z, weight
    end

    def ==(other)
      @x      == other.x &&
      @y      == other.y &&
      @z      == other.z &&
      @weight == other.weight
    end

    def +(other)
      @x      += other.x
      @y      += other.y
      @z      += other.z
      @weight += other.weight
    end

    def -(other)
      @x      -= other.x
      @y      -= other.y
      @z      -= other.z
      @weight -= other.weight
    end

    def *(other)
      @x      *= other.x
      @y      *= other.y
      @z      *= other.z
      @weight *= other.weight
    end

    def /(other)
      @x      /= other.x
      @y      /= other.y
      @z      /= other.z
      @weight /= other.weight
    end

    def to_a
      [@x, @y, @z, @weight]
    end

    def to_s
      "X: #{@x}, Y: #{@y}, Z: #{@z}, Weight: #{@weight}"
    end
  end
end