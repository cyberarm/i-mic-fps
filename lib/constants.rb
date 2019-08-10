class IMICFPS
  GAME_ROOT_PATH = File.expand_path("..", File.dirname(__FILE__))

  TextureCoordinate = Struct.new(:u, :v, :weight)
  Point = Struct.new(:x, :y)
  Color = Struct.new(:red, :green, :blue, :alpha)
  Face  = Struct.new(:vertices, :uvs, :normals, :colors, :material, :smoothing)
end