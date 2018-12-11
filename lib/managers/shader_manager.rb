class IMICFPS
  class ShaderManager
    SHADERS = {}
    def self.add_shader(name, shader)
      SHADERS[name] = shader
    end

    def self.shader(name)
      SHADERS[name]
    end
  end
end