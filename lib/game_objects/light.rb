class IMICFPS
  class Light
    attr_reader :light_id
    attr_accessor :ambient, :diffuse, :specular, :position, :intensity
    def initialize(id:,
                   ambient: Vector.new(0.5, 0.5, 0.5, 1),
                   diffuse: Vector.new(1, 0.5, 0, 1), specular: Vector.new(0.2, 0.2, 0.2, 1),
                   position: Vector.new(0, 0, 0, 0), intensity: 1
                  )
      @light_id = id
      @intensity = intensity

      @ambient  = ambient
      @diffuse  = diffuse
      @specular = specular
      @position = position
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
