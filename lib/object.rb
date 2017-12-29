class IMICFPS
  class Object
    Vertex = Struct.new("Vertex", :x, :y, :z)

    attr_accessor :vertexes, :texures, :normals, :faces

    def initialize(object = "objects/cube.obj")
      @level = File.open(object, 'r')
      @vertexes = []
      @textures = []
      @normals = []
      @faces = []
      parse
    end

    def parse
      @level.each_line do |line|
        line = line.strip

        array = line.split(' ')
        case array[0]
        when 'v'
          vert = Vertex.new(Float(array[1]), Float(array[2]), Float(array[3]))
          @vertexes << vert
        when 'vt'
          p array
          # vert = Vertex.new(Float(array[1]), Float(array[2]), Float(array[3]))
          # @textures << vert

        when 'vn'
          vert = Vertex.new(Float(array[1]), Float(array[2]), Float(array[3]))
          @normals << vert

        when 'f'
          vert = []
          norm = []
          array[1..3].each do |f|
            vert << f.split("/")[0]
            norm << f.split("/")[2]
          end

          vert.each_with_index do |v, index|
            face = [@vertexes[Integer(v)-1], @normals[Integer(norm[index])-1]]
            @faces << face
          end
        end
      end
    end
  end
end
