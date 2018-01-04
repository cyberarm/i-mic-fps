class IMICFPS
  class Object
    include GL
    include GLU
    TextureCoordinate = Struct.new(:u, :v, :weight)
    Vertex = Struct.new(:x, :y, :z, :weight)
    Color = Struct.new(:red, :green, :blue)

    attr_accessor :vertexes, :texures, :normals, :faces

    def initialize(object = "objects/cube.obj")
      @object_path = object
      @file = File.open(object, 'r')
      @material_file = nil
      @vertexes = []
      @textures = []
      @normals = []
      @faces = []
      parse
      @color = Color.new(1.0,1.0,1.0)
    end

    def parse
      @file.each_line do |line|
        line = line.strip

        array = line.split(' ')
        case array[0]
        when 'mtllib'
          @material_file = array[1]
          puts @material_file
          parse_mtllib
        when 'usemtl'
          # PI*(r*r)
          set_material(array[1])
        when 'o'
          change_object(array[1])
        when 'v'
          add_vertex(array)
        when 'vt'
          add_texture_coordinate(array)

        when 'vn'
          add_normal(array)

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

    def parse_mtllib
      file = File.open(@object_path.sub(File.basename(@object_path), '')+@material_file, 'r')
      file.readlines.each do |line|
        array = line.strip.split(' ')
        p array
        case array.first
        when 'newmtl'
        when 'Ns' # Specular Exponent
        when 'Ka' # Ambient
        when 'Kd' # Diffuse
        when 'Ks' # Specular
        when 'Ke' # Emissive
        when 'Ni' # Unknown (Blender Specific?)
        when 'd'  # Dissolved (Transparency)
        when 'illum' # Illumination model
        end
      end
    end

    def add_vertex(array)
      vert = nil
      if array.size == 5
        vert = Vertex.new(Float(array[1]), Float(array[2]), Float(array[3]), Float(array[4]))
      elsif array.size == 4
        vert = Vertex.new(Float(array[1]), Float(array[2]), Float(array[3]), 1.0)
      end
      @vertexes << vert
    end

    def add_normal(array)
      vert = nil
      if array.size == 5
        vert = Vertex.new(Float(array[1]), Float(array[2]), Float(array[3]), Float(array[4]))
      elsif array.size == 4
        vert = Vertex.new(Float(array[1]), Float(array[2]), Float(array[3]), 1.0)
      end
      @normals << vert
    end

    def add_texture_coordinate(array)
      texture = nil
      if array.size == 4
        texture = Vertex.new(Float(array[1]), Float(array[2]), Float(array[3]))
      elsif array.size == 3
        texture = Vertex.new(Float(array[1]), Float(array[2]), 0.0)
      end
      @textures << texture
    end

    def draw
      glEnable(GL_CULL_FACE)
      glEnable(GL_COLOR_MATERIAL)
      glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)
      glBegin(GL_TRIANGLES) # begin drawing model
        self.faces.each do |vert|
          vertex = vert[0]
          normal = vert[1]

          glColor3f(@color.red, @color.green, @color.blue)
          glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, [@color.red, @color.green, @color.blue, 1.0])
          glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, [@color.red, @color.green, @color.blue, 1.0])
          glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, [1,1,1,1])
          glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, [10.0])

          glNormal3f(normal.x, normal.y, normal.z)
          glVertex3f(vertex.x, vertex.y, vertex.z)
        end
      glEnd
      glDisable(GL_CULL_FACE)
      glDisable(GL_COLOR_MATERIAL)
    end
  end
end
