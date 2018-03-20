class IMICFPS
  class Model
    def self.supported_models
      ["Wavefront OBJ"]
    end

    CACHE = {}

    include OpenGL
    include GLU

    attr_accessor :x, :y, :z, :scale
    attr_accessor :visible, :renderable
    attr_accessor :x_rotation, :y_rotation, :z_rotation

    def initialize(type:, file_path:, x: 0, y: 0, z: 0, scale: MODEL_METER_SCALE, backface_culling: true)
      @type = type
      @file_path = file_path
      @x,@y,@z,@scale = x,y,z,scale
      @backface_culling = backface_culling
      @visible = true
      @renderable = true
      @x_rotation,@y_rotation,@z_rotation = 0,0,0

      @model = nil

      unless load_model_from_cache
        case type
        when :obj
          p file_path
          @model = Wavefront::Model.new(@file_path)
        else
          raise "Unsupported model type, supported models are: #{Model.supported_models.join(', ')}"
        end
      end

      cache_model

      ObjectManager.add_object(self)

      setup

      return self
    end

    def setup
    end

    def draw
      handleGlError

      glEnable(GL_NORMALIZE)
      glPushMatrix
      glTranslatef(x,y,z)
      glScalef(scale, scale, scale)
      glRotatef(@x_rotation,1.0, 0, 0)
      glRotatef(@y_rotation,0, 1.0, 0)
      glRotatef(@z_rotation,0, 0, 1.0)

      handleGlError
      @model.draw(@x, @y, @z, @scale, @backface_culling)
      handleGlError

      glPopMatrix
      handleGlError
    end

    def update
    end

    def load_model_from_cache
      found = false
      if CACHE[@type].is_a?(Hash)
        if CACHE[@type][@file_path]
          @model = CACHE[@type][@file_path]
          puts "Used cached model for: #{@file_path.split('/').last}"
          found = true
        end
      end

      return found
    end

    def cache_model
      CACHE[@type] = {} unless CACHE[@type].is_a?(Hash)
      CACHE[@type][@file_path] = @model
    end

    def handleGlError
      e = glGetError()
      if e != GL_NO_ERROR
        $stderr.puts "OpenGL error in: #{gluErrorString(e)} (#{e})\n"
        exit
      end
    end
  end
end
