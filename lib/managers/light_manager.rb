class IMICFPS
  class LightManager
    MAX_LIGHTS = OpenGL::GL_MAX_LIGHTS
    LIGHTS = []

    def self.add_light(model)
      LIGHTS << model
    end

    def self.find_light()
    end

    def self.lights
      LIGHTS
    end

    def self.light_count
      LIGHTS.count+1
    end

    def self.clear_lights
      LIGHTS.clear
    end
  end
end
