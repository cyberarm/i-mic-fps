class IMICFPS
  class Wavefront
    class Material
      attr_accessor :name, :ambient, :diffuse, :specular
      def initialize(name)
        @name    = name
        @ambient = Wavefront::Model::Color.new(1, 1, 1, 1)
        @diffuse = Wavefront::Model::Color.new(1, 1, 1, 1)
        @specular= Wavefront::Model::Color.new(1, 1, 1, 1)
      end
    end
  end
end
