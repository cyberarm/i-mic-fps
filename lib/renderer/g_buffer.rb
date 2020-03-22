class IMICFPS
  class GBuffer
    include CommonMethods

    def initialize
      @framebuffer = nil
      @buffers = [:position, :diffuse, :normal, :texcoord]
      @textures = {}
      @ready = false

      create_framebuffer
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

    def clean_up
      glDeleteFramebuffers(@framebuffer)

      @textures.values.each do |id|
        glDeleteTextures(id)
      end
    end
  end
end