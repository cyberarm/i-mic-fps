class IMICFPS
  class Wavefront
    class Material
      include OpenGL
      attr_accessor :name, :ambient, :diffuse, :specular
      attr_reader :texture
      def initialize(name)
        @name    = name
        @ambient = Wavefront::Model::Color.new(1, 1, 1, 1)
        @diffuse = Wavefront::Model::Color.new(1, 1, 1, 1)
        @specular= Wavefront::Model::Color.new(1, 1, 1, 1)
        @texture = nil
        @texture_id = nil
      end

      def set_texture(texture_path)
        puts "#{name} texture #{texture_path}"
        @texture = Gosu::Image.new(texture_path, retro: true)
        array_of_pixels = @texture.to_blob
        if @texture.gl_tex_info
          @texture_id = @texture.gl_tex_info.tex_name
        else
          puts "Allocating..."
          tex_names_buf = ' ' * 8
          glGenTextures(1, tex_names_buf)
          @texture_id = tex_names_buf.unpack('L2').first
        end
        glBindTexture(GL_TEXTURE_2D, @texture_id)
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, @texture.width, @texture.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, array_of_pixels)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
        glGenerateMipmap(GL_TEXTURE_2D)
      end

      def texture_id
        @texture_id
      end
    end
  end
end
