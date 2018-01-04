class IMICFPS
  class Wavefront
    class Object
      attr_reader :name
      attr_accessor :faces

      def initialize(name)
        @name = name
        @vertexes = []
        @textures = []
        @normals  = []
        @faces    = []
      end
    end
  end
end
