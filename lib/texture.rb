class IMICFPS
  class Texture
    include CommonMethods

    CACHE = {}

    def self.release_textures
      CACHE.values.each do |id|
        glDeleteTextures(id)
      end
    end

    attr_reader :id
    def initialize(path: nil, image: nil, retro: false)
      raise "keyword :path or :image must be provided!" if path.nil? && image.nil?
      @retro = retro

      if path.is_a?(Array)
        if path.size > 1
          path = "#{GAME_ROOT_PATH}/assets/#{path.join("/")}"
        else
          path = path.first
        end
      end

      @id = create_from_image(path ? path : image)
    end

    def from_cache(path)
      CACHE[path] = create_from_image(path) unless CACHE[path]

      return CACHE[path]
    end

    def create_from_image(path_or_image)
      puts "Allocating texture for: #{path_or_image}" if window.config.get(:debug_options, :stats)

      texture = nil
      if path_or_image.is_a?(Gosu::Image)
        texture = path_or_image
      else
        texture = Gosu::Image.new(path_or_image, retro: false)
      end

      array_of_pixels = texture.to_blob

      tex_names_buf = ' ' * 4
      glGenTextures(1, tex_names_buf)
      texture_id = tex_names_buf.unpack('L2').first

      glBindTexture(GL_TEXTURE_2D, texture_id)
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texture.width, texture.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, array_of_pixels)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST) if @retro
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR) unless @retro
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
      glGenerateMipmap(GL_TEXTURE_2D)
      gl_error?

      return texture_id
    end
  end
end