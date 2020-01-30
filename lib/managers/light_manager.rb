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

    def available_light
      raise "Using to many lights, #{light_count}/#{LightManager::MAX_LIGHTS}" if light_count > LightManager::MAX_LIGHTS
      puts "OpenGL::GL_LIGHT#{light_count}" if $window.config.get(:debug_options, :stats)
      Object.const_get "OpenGL::GL_LIGHT#{light_count}"
    end
  end
end
