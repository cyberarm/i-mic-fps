class IMICFPS
  class Light
    include OpenGL
    MAX_LIGHTS = GL_MAX_LIGHTS-1
    attr_reader :x, :y, :z, :ambient, :diffuse, :specular, :position
    def self.number_of_lights
      @number_of_lights ||= 0
    end

    # use as Light.number_of_lights+=n
    def self.number_of_lights=(int)
      @number_of_lights = int
    end

    def initialize(x,y,z)
      @ambient  = [0.0, 0.0, 0.0, 1].pack("f*")
      @diffuse  = [1, 0.5, 0, 1].pack("f*")
      @specular = [0.0, 0.0, 0.0, 1].pack("f*")
      @position  = [0, 0, 0, 0].pack("f*")
      @light_id = available_light
    end

    def available_light
      raise "Using to many lights, #{Light.number_of_lights}/#{MAX_LIGHTS}" if Light.number_of_lights > MAX_LIGHTS
      Light.number_of_lights+=1
      puts "OpenGL::GL_LIGHT#{Light.number_of_lights}"
      @light_id = Object.const_get "OpenGL::GL_LIGHT#{Light.number_of_lights}"
    end

    def ambient=(array)
      @ambient = array.pack("f*")
    end

    def diffuse=(array)
      @diffuse = array.pack("f*")
    end

    def specular=(array)
      @specular = array.pack("f*")
    end

    def position=(array)
      @position = array.pack("f*")
    end

    def draw
      glLightfv(@light_id, GL_AMBIENT, @ambient)
      glLightfv(@light_id, GL_DIFFUSE, @diffuse)
      glLightfv(@light_id, GL_SPECULAR, @specular)
      glLightfv(@light_id, GL_POSITION, @position)
      glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER, 1)
      glEnable(GL_LIGHTING)
      glEnable(@light_id)
    end
  end
end
