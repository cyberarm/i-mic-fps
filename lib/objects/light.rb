class IMICFPS
  class Light
    include OpenGL
    attr_reader :ambient, :diffuse, :specular, :position, :light_id
    attr_accessor :x, :y, :z, :intensity
    def initialize(x:,y:,z:, ambient: Vertex.new(0.5, 0.5, 0.5, 1),
                   diffuse: Vertex.new(1, 0.5, 0, 1), specular: Vertex.new(0.2, 0.2, 0.2, 1),
                   position: Vertex.new(x, y, z, 0), intensity: 1)
      @x,@y,@z = x,y,z
      @intensity = intensity

      self.ambient   = ambient
      self.diffuse   = diffuse
      self.specular  = specular
      self.position  = position
      @light_id = available_light

      LightManager.add_light(self)
    end

    def available_light
      raise "Using to many lights, #{LightManager.light_count}/#{LightManager::MAX_LIGHTS}" if LightManager.light_count > LightManager::MAX_LIGHTS
      puts "OpenGL::GL_LIGHT#{LightManager.light_count}"
      @light_id = Object.const_get "OpenGL::GL_LIGHT#{LightManager.light_count}"
    end

    def ambient=(color)
      @ambient = convert(color).pack("f*")
    end

    def diffuse=(color)
      @diffuse = convert(color, true).pack("f*")
    end

    def specular=(color)
      @specular = convert(color, true).pack("f*")
    end

    def position=(vertex)
      @position = convert(vertex).pack("f*")
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

    def convert(struct, apply_intensity = false)
      if apply_intensity
        return struct.to_a.compact.map{|i| i*@intensity}
      else
        return struct.to_a.compact
      end
    end
  end
end
