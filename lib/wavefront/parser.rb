class IMICFPS
  class Wavefront
    module Parser
      TextureCoordinate = Struct.new(:u, :v, :weight)
      Vertex = Struct.new(:x, :y, :z, :weight)
      Color = Struct.new(:red, :green, :blue, :alpha)

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
        recalculate_bounding_box(vert, @bounding_box)
        recalculate_bounding_box(vert, @current_object.bounding_box)
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

      def recalculate_bounding_box(vertex, bounding_box)
        # Set a default relative to the model
        unless bounding_box.min_x.is_a?(Float)
          bounding_box.min_x = vertex.x
          bounding_box.min_y = vertex.y
          bounding_box.min_z = vertex.z

          bounding_box.max_x = vertex.x
          bounding_box.max_y = vertex.y
          bounding_box.max_z = vertex.z
        end

        bounding_box.min_x = vertex.x if vertex.x < bounding_box.min_x
        bounding_box.min_y = vertex.y if vertex.y < bounding_box.min_y
        bounding_box.min_z = vertex.z if vertex.z < bounding_box.min_z

        bounding_box.max_x = vertex.x if vertex.x > bounding_box.max_x
        bounding_box.max_y = vertex.y if vertex.y > bounding_box.max_y
        bounding_box.max_z = vertex.z if vertex.z > bounding_box.max_z
      end
    end
  end
end
