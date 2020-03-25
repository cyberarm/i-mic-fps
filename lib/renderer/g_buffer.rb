class IMICFPS
  class GBuffer
    include CommonMethods

    attr_reader :screen_vbo, :vertices, :uvs
    def initialize
      @framebuffer = nil
      @buffers = [:position, :diffuse, :normal, :texcoord]
      @textures = {}
      @screen_vbo = nil
      @ready = false

      @vertices = [
        -1.0, -1.0, 0,
        1.0,  -1.0, 0,
        -1.0,  1.0, 0,
        
        -1.0,  1.0, 0,
        1.0,  -1.0, 0,
        1.0,   1.0, 0,
    ].freeze

      @uvs = [
        0, 1,
        1, 1,
        0, 0,

        0, 0,
        1, 1,
        1, 0
      ].freeze

      create_framebuffer
      create_screen_vbo
    end

    def create_framebuffer
      buffer = ' ' * 8
      glGenFramebuffers(1, buffer)
      @framebuffer = buffer.unpack('L2').first

      glBindFramebuffer(GL_DRAW_FRAMEBUFFER, @framebuffer)

      create_textures

      status = glCheckFramebufferStatus(GL_FRAMEBUFFER)

      if status != GL_FRAMEBUFFER_COMPLETE
        message = ""

        case status
        when GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT
          message = "GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT"
        when GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT
          message = "GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT"
        when GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER
          message = "GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER"
        when GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER
          message = "GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER"
        when GL_FRAMEBUFFER_UNSUPPORTED
          message = "GL_FRAMEBUFFER_UNSUPPORTED"
        else
          message = "Unknown error!"
        end
        puts "Incomplete framebuffer: #{status}\nError: #{message}"
      else
        @ready = true
      end

      glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0)
    end

    def create_textures
      @buffers.size.times do |i|
        buffer = ' ' * 8
        glGenTextures(1, buffer)
        texture_id = buffer.unpack('L2').first
        @textures[@buffers[i]] = texture_id

        glBindTexture(GL_TEXTURE_2D, texture_id)
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16F, window.width, window.height, 0, GL_RGB, GL_FLOAT, nil)
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + i, GL_TEXTURE_2D, texture_id, 0)
      end

      buffer = ' ' * 8
      glGenTextures(1, buffer)
      texture_id = buffer.unpack('L2').first
      @textures[:depth] = texture_id

      glBindTexture(GL_TEXTURE_2D, texture_id)
      glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT32F, window.width, window.height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, nil)
      glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, texture_id, 0)

      draw_buffers = [ GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1, GL_COLOR_ATTACHMENT2, GL_COLOR_ATTACHMENT3 ]
      glDrawBuffers(draw_buffers.size, draw_buffers.pack("I*"))
    end

    def create_screen_vbo
      buffer = ' ' * 8
      glGenVertexArrays(1, buffer)
      @screen_vbo = buffer.unpack('L2').first

      buffer = " " * 4
      glGenBuffers(1, buffer)
      @positions_buffer_id = buffer.unpack('L2').first

      buffer = " " * 4
      glGenBuffers(1, buffer)
      @uvs_buffer_id = buffer.unpack('L2').first

      glBindVertexArray(@screen_vbo)
      glBindBuffer(GL_ARRAY_BUFFER, @positions_buffer_id)
      glBufferData(GL_ARRAY_BUFFER, @vertices.size * Fiddle::SIZEOF_FLOAT, @vertices.pack("f*"), GL_STATIC_DRAW);
      glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, nil)

      glBindBuffer(GL_ARRAY_BUFFER, @uvs_buffer_id)
      glBufferData(GL_ARRAY_BUFFER, @uvs.size * Fiddle::SIZEOF_FLOAT, @uvs.pack("f*"), GL_STATIC_DRAW);
      glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, nil)

    end

    def bind_for_writing
      glBindFramebuffer(GL_DRAW_FRAMEBUFFER, @framebuffer)
    end

    def bind_for_reading
      glBindFramebuffer(GL_READ_FRAMEBUFFER, @framebuffer)
    end

    def set_read_buffer(buffer)
      glReadBuffer(GL_COLOR_ATTACHMENT0 + @textures.keys.index(buffer))
    end

    def unbind_framebuffer
      glBindFramebuffer(GL_FRAMEBUFFER, 0)
    end

    def texture(type)
      @textures[type]
    end

    def clean_up
      glDeleteFramebuffers(@framebuffer)

      @textures.values.each do |id|
        glDeleteTextures(id)
      end

      glDeleteBuffers(@positions_buffer_id)
      glDeleteBuffers(@uvs_buffer_id)
      glDeleteVertexArrays(@screen_vbo)
    end
  end
end