class IMICFPS
  TextureCoordinate = Struct.new(:u, :v, :weight)
  Vertex = Struct.new(:x, :y, :z, :weight)
  Point = Struct.new(:x, :y)
  Color = Struct.new(:red, :green, :blue, :alpha)

  module ObjectManager # Get included into GameState context
    def add_object(model)
      @game_objects << model
    end

    def find_object()
    end

    def remove_object()
    end

    def game_objects
      @game_objects
    end
  end
end
