class IMICFPS
  class Wavefront
    class Model
      include GL
      include GLU
      TextureCoordinate = Struct.new(:u, :v, :weight)
      Vertex = Struct.new(:x, :y, :z, :weight)
      Color = Struct.new(:red, :green, :blue)

      attr_accessor :objects, :vertexes, :texures, :normals, :faces

      def initialize(object = "objects/cube.obj")
        @object_path = object
        @file = File.open(object, 'r')
        @material_file = nil
        @current_object= nil
        @vertex_count  = 0
        @objects  = []
        @vertices = []
        @uvs      = []
        @normals  = []
        @faces    = []
        @color = Color.new(0.5, 0.5, 0.5)
        parse
        face_count = 0
        @objects.each {|o| face_count+=o.faces.size}
        @objects.each_with_index do |o, i|
          puts "OBJECT FACES: Name: #{o.name} #{o.faces.size}, array size divided by 3: #{o.faces.size.to_f/3.0}"
        end
      end

      def draw
        glEnable(GL_CULL_FACE)
        glEnable(GL_COLOR_MATERIAL)
        glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)
        glBegin(GL_TRIANGLES) # begin drawing model
        # @objects.each_with_index do |o, i|
          @faces.each do |vert|
            vertex = vert[0]
            uv     = vert[1]
            normal = vert[2]
            color = vert[3]
            # p vert if i > 0

            glColor3f(color.red, color.green, color.blue)
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
        # end
      end

      def parse
        lines = 0
        @file.each_line do |line|
          lines+=1
          line = line.strip

          array = line.split(' ')
          case array[0]
          when 'mtllib'
            @material_file = array[1]
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
            verts = []
            uvs   = []
            norms = []
            array[1..3].each do |f|
              verts << f.split("/")[0]
              uvs   << f.split("/")[1]
              norms << f.split("/")[2]
            end

            verts.each_with_index do |v, index|
              if uvs.first != ""
                face = [@vertices[Integer(v)-1], @uvs[Integer(uvs[index])-1], @normals[Integer(norms[index])-1], material]
              else
                face = [@vertices[Integer(v)-1], nil, @normals[Integer(norms[index])-1], material]
              end
              @current_object.faces << face
              @faces << face
            end
          end
        end

        puts "Total Lines: #{lines}"
      end

      def parse_mtllib
        file = File.open(@object_path.sub(File.basename(@object_path), '')+@material_file, 'r')
        file.readlines.each do |line|
          array = line.strip.split(' ')
          # puts array.join
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

      def change_object(name)
        @objects << Object.new(name)
        @current_object = @objects.last
      end

      def set_material(name)
        # @current_object.
      end
      def material
        Color.new(rand(0.1..1.0), rand(0.1..1.0), rand(0.1..1.0))
      end

      def faces_count
        count = 0
        @objects.each {|o| count+=o.faces.count}
        return count
      end

      def add_vertex(array)
        @vertex_count+=1
        vert = nil
        if array.size == 5
          vert = Vertex.new(Float(array[1]), Float(array[2]), Float(array[3]), Float(array[4]))
        elsif array.size == 4
          vert = Vertex.new(Float(array[1]), Float(array[2]), Float(array[3]), 1.0)
        else
          raise
        end
        @vertices << vert
      end

      def add_normal(array)
        vert = nil
        if array.size == 5
          vert = Vertex.new(Float(array[1]), Float(array[2]), Float(array[3]), Float(array[4]))
        elsif array.size == 4
          vert = Vertex.new(Float(array[1]), Float(array[2]), Float(array[3]), 1.0)
        else
          raise
        end
        @normals << vert
      end

      def add_texture_coordinate(array)
        texture = nil
        if array.size == 4
          texture = Vertex.new(Float(array[1]), Float(array[2]), Float(array[3]))
        elsif array.size == 3
          texture = Vertex.new(Float(array[1]), Float(array[2]), 0.0)
        else
          raise
        end
        @uvs << texture
      end
    end
  end
end
