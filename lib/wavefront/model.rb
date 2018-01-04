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
        @color = Color.new(0.5, 0.5, 0.5)
        @verts = []
        @norms = []
        parse
        vertex_count = 0
        face_count   = 0
        @objects.each {|o| face_count+=o.vertexes.count}
        puts "vertexes count: #{@vertex_count} Objects: #{face_count}"
        form_faces
        @objects.each do |o|
          puts "LLF-#{o.faces.size}"
        end
      end

      def draw
        glEnable(GL_CULL_FACE)
        glEnable(GL_COLOR_MATERIAL)
        glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)
        glBegin(GL_TRIANGLES) # begin drawing model
        @objects.each do |o|
          puts "LL..#{o.faces.size}"
          o.faces.each do |vert|
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
            array[1..3].each do |f|
              @verts << f.split("/")[0]
              @norms << f.split("/")[2]
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
        @current_object.vertexes << vert
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
        @current_object.normals << vert
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
        @current_object.textures << texture
      end

      def form_faces
        @verts.each_with_index do |v, index|
          active_object = nil
          # Look for active object
          search_index = Integer(v)-1
          local_search = 0
          search_object_index = 0
          found = false
          @objects.each_with_index do |o, i|
            local_search=search_index-i
            search_object_index = i
            if  local_search.between?(local_search, local_search+o.vertexes.count-1)
              active_object = o
              found = true
              break
            end
          end

          raise "active_object is nil!" if active_object == nil
          face = [active_object.vertexes[Integer(v)-local_search-1], active_object.normals[Integer(@norms[index])-1]]
          if face.last == nil
            p Integer(v)-local_search-1
            p active_object.normals[@norms[index].to_i]
            p Integer(@norms[index])-local_search-1
            puts "V: #{active_object.vertexes.count-1}, T: #{Integer(v)-1}"
            puts "Vertex: #{v}/#{Integer(v)-1}/#{Integer(v)-local_search-1}
            Normal: #{index}/#{Integer(@norms[index])-1}/#{Integer(@norms[index])-local_search-1}"
            raise "Bad data!"
          end

          active_object.faces << face
        end
      end
    end
  end
end
