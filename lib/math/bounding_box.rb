class IMICFPS
  class BoundingBox
    attr_accessor :min_x, :min_y, :min_z, :max_x, :max_y, :max_z

    def initialize(min_x = 0.0, min_y = 0.0, min_z = 0.0, max_x = 0.0, max_y = 0.0, max_z = 0.0)
      @min_x = min_x
      @min_y = min_y
      @min_z = min_z

      @max_x = max_x
      @max_y = max_y
      @max_z = max_z
    end

    def ==(other)
      min_x == other.min_x &&
      min_y == other.min_y &&
      min_z == other.min_z &&
      max_x == other.max_x &&
      max_y == other.max_y &&
      max_z == other.max_z
    end

    # returns a new bounding box that includes both bounding boxes
    def union(other)
      temp = BoundingBox.new
      temp.min_x = [min_x, other.min_x].min
      temp.min_y = [min_y, other.min_y].min
      temp.min_z = [min_z, other.min_z].min

      temp.max_x = [max_x, other.max_x].max
      temp.max_y = [max_y, other.max_y].max
      temp.max_z = [max_z, other.max_z].max

      return temp
    end

    # returns boolean
    def intersect(other)
      (min_x <= other.max_x && max_x >= other.min_x) &&
      (min_y <= other.max_y && max_y >= other.min_y) &&
      (min_z <= other.max_z && max_z >= other.min_z)
    end

    def difference(other)
      temp = BoundingBox.new
      temp.min_x = min_x - other.min_x
      temp.min_y = min_y - other.min_y
      temp.min_z = min_z - other.min_z

      temp.max_x = max_x - other.max_x
      temp.max_y = max_y - other.max_y
      temp.max_z = max_z - other.max_z

      return temp
    end

    def volume
      width * height * depth
    end

    def width
      @max_x - @min_x
    end

    def height
      @max_y - @min_y
    end

    def depth
      @max_z - @min_z
    end

    def normalize(entity)
      temp = BoundingBox.new
      temp.min_x = min_x.to_f * entity.scale
      temp.min_y = min_y.to_f * entity.scale
      temp.min_z = min_z.to_f * entity.scale

      temp.max_x = max_x.to_f * entity.scale
      temp.max_y = max_y.to_f * entity.scale
      temp.max_z = max_z.to_f * entity.scale

      return temp
    end

    def normalize_with_offset(entity)
      temp = BoundingBox.new
      temp.min_x = min_x.to_f * entity.scale + entity.position.x
      temp.min_y = min_y.to_f * entity.scale + entity.position.y
      temp.min_z = min_z.to_f * entity.scale + entity.position.z

      temp.max_x = max_x.to_f * entity.scale + entity.position.x
      temp.max_y = max_y.to_f * entity.scale + entity.position.y
      temp.max_z = max_z.to_f * entity.scale + entity.position.z

      return temp
    end
  end
end