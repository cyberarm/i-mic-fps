class IMICFPS
  class Wavefront
    class Model
      include OpenGL
      include GLU
      TextureCoordinate = Struct.new(:u, :v, :weight)
      Vertex = Struct.new(:x, :y, :z, :weight)
      Color = Struct.new(:red, :green, :blue, :alpha)

      attr_accessor :objects, :materials, :vertexes, :texures, :normals, :faces
      attr_accessor :x, :y, :z

      def initialize(object = "objects/cube.obj")
        @x, @y, @z = 0, 0, 0
        @object_path = object
        @file = File.open(object, 'r')
        @material_file  = nil
        @current_object = nil
        @current_material=nil
        @vertex_count  = 0
        @objects  = []
        @materials= {}
        @vertices = []
        @uvs      = []
        @normals  = []
        @faces    = []
        @smoothing= 0
        parse
        face_count = 0
        @objects.each {|o| face_count+=o.faces.size}
        @objects.each_with_index do |o, i|
          puts "OBJECT FACES: Name: #{o.name} #{o.faces.size}, array size divided by 3: #{o.faces.size.to_f/3.0}"
        end
        $window.number_of_faces+=face_count
        @model_has_texture = false
        @materials.each do |key, material|
          if material.texture_id
            @model_has_texture = true
            @textured_material = key
          end
        end
      end

      def handleGlError
        e = glGetError()
        if e != GL_NO_ERROR
          $stderr.puts "OpenGL error in: #{gluErrorString(e)} (#{e})\n"
          exit
        end
      end

      def draw(x, y, z, scale = MODEL_METER_SCALE, back_face_culling = true)
        handleGlError
        render(x,y,z, scale, back_face_culling)
        handleGlError
      end

      def render(x,y,z, scale, back_face_culling)
        glEnable(GL_NORMALIZE)
        glPushMatrix
        glTranslatef(x,y,z)
        glScalef(scale, scale, scale)
        @objects.each_with_index do |o, i|
          glEnable(GL_CULL_FACE) if back_face_culling
          glEnable(GL_COLOR_MATERIAL)
          glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)
          glShadeModel(GL_FLAT) unless o.faces.first[4]
          glShadeModel(GL_SMOOTH) if o.faces.first[4]
          glEnableClientState(GL_VERTEX_ARRAY)
          glEnableClientState(GL_COLOR_ARRAY)
          glEnableClientState(GL_NORMAL_ARRAY)
          if @model_has_texture
            glEnable(GL_TEXTURE_2D)
            glBindTexture(GL_TEXTURE_2D, @materials[@textured_material].texture_id)
            glEnableClientState(GL_TEXTURE_COORD_ARRAY)
            glTexCoordPointer(3, GL_FLOAT, 0, o.flattened_textures)
          end
          glVertexPointer(4, GL_FLOAT, 0, o.flattened_vertices)
          glColorPointer(3, GL_FLOAT, 0, o.flattened_materials)
          glNormalPointer(GL_FLOAT, 0, o.flattened_normals)

          glDrawArrays(GL_TRIANGLES, 0, o.flattened_vertices_size/4)

          glDisableClientState(GL_VERTEX_ARRAY)
          glDisableClientState(GL_COLOR_ARRAY)
          glDisableClientState(GL_NORMAL_ARRAY)
          if @model_has_texture
            glDisableClientState(GL_TEXTURE_COORD_ARRAY)
            # glBindTexture(GL_TEXTURE_2D, 0)
            glDisable(GL_TEXTURE_2D)
          end
          glDisable(GL_CULL_FACE) if back_face_culling
          glDisable(GL_COLOR_MATERIAL)
        end
        glPopMatrix
        $window.number_of_faces+=self.faces.size
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
            set_material(array[1])
          when 'o'
            change_object(array[1])
          when 's'
            set_smoothing(array[1])
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
                face = [@vertices[Integer(v)-1], @uvs[Integer(uvs[index])-1], @normals[Integer(norms[index])-1], material, @smoothing]
              else
                face = [@vertices[Integer(v)-1], nil, @normals[Integer(norms[index])-1], material, @smoothing]
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
            material = Material.new(array.last)
            @current_material = array.last
            @materials[array.last] = material
          when 'Ns' # Specular Exponent
          when 'Ka' # Ambient
            @materials[@current_material].ambient  = Color.new(Float(array[1]), Float(array[2]), Float(array[3]))
          when 'Kd' # Diffuse
            @materials[@current_material].diffuse  = Color.new(Float(array[1]), Float(array[2]), Float(array[3]))
          when 'Ks' # Specular
            @materials[@current_material].specular = Color.new(Float(array[1]), Float(array[2]), Float(array[3]))
          when 'Ke' # Emissive
          when 'Ni' # Unknown (Blender Specific?)
          when 'd'  # Dissolved (Transparency)
          when 'illum' # Illumination model
          when 'map_Kd'
            @materials[@current_material].set_texture(array[1])
          end
        end
      end

      def change_object(name)
        @objects << Object.new(name)
        @current_object = @objects.last
      end

      def set_smoothing(value)
        if value == "1"
          @smoothing = true
        else
          @smoothing = false
        end
      end

      def set_material(name)
        @current_material = name
      end

      def material
        @materials[@current_material]
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
        @current_object.vertices << vert
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
        @current_object.normals << vert
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
        @current_object.textures << texture
        @uvs << texture
      end
    end
  end
end
