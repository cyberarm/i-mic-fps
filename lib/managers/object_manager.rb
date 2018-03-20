class IMICFPS
  TextureCoordinate = Struct.new(:u, :v, :weight)
  Vertex = Struct.new(:x, :y, :z, :weight)
  Point = Struct.new(:x, :y)
  Color = Struct.new(:red, :green, :blue, :alpha)

  class ObjectManager
    OBJECTS = []
    def self.add_object(model)
      OBJECTS << model
    end

    def self.find_object()
    end

    def self.objects
      OBJECTS
    end
  end
end
