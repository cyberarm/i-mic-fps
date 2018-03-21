class IMICFPS
  class Wavefront
    class Object
      attr_reader :parent, :name, :vertices, :textures, :normals, :bounding_box, :debug_color
      attr_accessor :faces

      def initialize(parent, name)
        @parent = parent
        @name = name
        @vertices = []
        @textures = []
        @normals  = []
        @faces    = []
        @bounding_box = BoundingBox.new(0,0,0, 0,0,0)
        @debug_color = Color.new(1.0,0.0,0.0)

        # Faces array packs everything:
        #   vertex   = index[0]
        #   uv       = index[1]
        #   normal   = index[2]
        #   material = index[3]
      end

      def flattened_vertices
        unless @vertices_list
          @debug_color = @faces.first[3].diffuse

          list = []
          @faces.each do |face|
            [face[0]].each do |v|
              next unless v
              list << v.x*@parent.scale#+@parent.x
              list << v.y*@parent.scale#+@parent.y
              list << v.z*@parent.scale#+@parent.z
              list << v.weight
            end
          end

          @vertices_list_size = list.size
          @vertices_list = list.pack("f*")
        end

        return @vertices_list
      end

      def flattened_vertices_size
        @vertices_list_size
      end

      def flattened_textures
        unless @textures_list
          list = []
          @faces.each_with_index do |face, i|
            [face[1]].each do |v|
              next unless v
              list << v.x
              list << v.y
              list << v.z
            end
          end

          @textures_list_size = list.size
          @textures_list = list.pack("f*")
        end

        return @textures_list
      end

      def flattened_normals
        unless @normals_list
          list = []
          @faces.each do |face|
            [face[2]].each do |v|
              next unless v
              list << v.x
              list << v.y
              list << v.z
              # list << v.weight
            end
          end

          @normals_list_size = list.size
          @normals_list = list.pack("f*")
        end

        return @normals_list
      end

      def flattened_materials
        unless @materials_list
          list = []
          @faces.each do |face|
            # p face
            [face[3]].each do |v|
              next unless v
              # p v
              # exit
              list << v.diffuse.red
              list << v.diffuse.green
              list << v.diffuse.blue
              # list << v.alpha
            end
          end

          @materials_list_size = list.size
          @materials_list = list.pack("f*")
        end

        return @materials_list
      end
    end
  end
end
