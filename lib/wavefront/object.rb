class IMICFPS
  class Wavefront
    class Object
      attr_reader :name, :vertices, :textures, :normals
      attr_accessor :faces

      def initialize(name)
        @name = name
        @vertices = []
        @textures = []
        @normals  = []
        @faces    = []

        # Faces array packs everything:
        #   vertex   = index[0]
        #   uv       = index[1]
        #   normal   = index[2]
        #   material = index[3]
      end

      def flattened_vertices
        unless @vertices_list
          list = []
          @faces.each do |face|
            [face[0]].each do |v|
              next unless v
              list << v.x
              list << v.y
              list << v.z
              list << v.weight
            end
          end

          @vertices_list = list
        end

        return @vertices_list
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

          @materials_list = list
        end

        return @materials_list
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
              # list << v.alpha
            end
          end

          @normals_list = list
        end

        return @normals_list
      end

      def flattened_textures
        unless @textures_list
          list = []
          @faces.each do |face|
            [face[1]].each do |v|
              next unless v
              list << v.x
              list << v.y
            end
          end

          @textures_list = list
        end

        return @textures_list
      end
    end
  end
end
