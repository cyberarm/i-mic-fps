class IMICFPS
  module LightManager
    MAX_LIGHTS = OpenGL::GL_MAX_LIGHTS

    def add_light(model)
      @lights << model
    end

    def find_light()
    end

    def lights
      @lights
    end

    def light_count
      @lights.count+1
    end

    def clear_lights
      @lights.clear
    end
  end
end
