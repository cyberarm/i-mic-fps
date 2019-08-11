class IMICFPS


  # A game object is any renderable thing
  class Entity
    include OpenGL
    include GLU
    include CommonMethods

    attr_accessor :scale, :visible, :renderable, :backface_culling
    attr_accessor :position, :rotation, :velocity
    attr_reader :name, :debug_color, :bounding_box, :collision, :physics, :mass, :drag

    def initialize(x: 0, y: 0, z: 0, bound_model: nil, scale: MODEL_METER_SCALE, backface_culling: true, auto_manage: true, manifest_file: nil)
      @position = Vector.new(x, y, z)
      @scale = scale
      @bound_model = bound_model
      @backface_culling = backface_culling
      @visible = true
      @renderable = true
      @rotation   = Vector.new(0, 0, 0)
      @velocity   = Vector.new(0, 0, 0)
      @drag       = 1.0

      @debug_color = Color.new(0.0, 1.0, 0.0)

      @collidable = [:static, :dynamic]
      # :dynamic => moves in response,
      # :static => does not move ever,
      # :none => no collision check, entities can pass through
      @collision  = :static
      @physics    = false # Entity affected by gravity and what not
      @mass       = 100 # kg

      @delta_time = Gosu.milliseconds
      @last_position = Vector.new(@position.x, @position.y, @position.z)

      setup

      if @bound_model
        @bound_model.model.entity = self
        @bound_model.model.objects.each { |o| o.scale = self.scale }
        @normalized_bounding_box = normalize_bounding_box_with_offset

        normalize_bounding_box
      end

      return self
    end

    def collidable?
      @collidable.include?(@collision)
    end

    def bind_model(package, name)
      model = ModelLoader.new(manifest_file: IMICFPS.assets_path + "/#{package}/#{name}/manifest.yaml", entity: @dummy_entity)

      raise "model isn't a model!" unless model.is_a?(ModelLoader)
      @bound_model = model
      @bound_model.model.entity = self
      @bound_model.model.objects.each { |o| o.scale = self.scale }
      @bounding_box = normalize_bounding_box_with_offset

      # box = normalize_bounding_box
    end

    def model
      @bound_model.model if @bound_model
    end

    def unbind_model
      @bound_model = nil
    end

    def setup
    end

    # Not advisable to put OpenGL code here, instead put it in Renderer.
    def draw
    end


    def update
      model.update
      @delta_time = Gosu.milliseconds

      unless at_same_position?
        @bounding_box = normalize_bounding_box_with_offset if model
      end
    end

    def debug_color=(color)
      @debug_color = color
    end

    def at_same_position?
      @position == @last_position
    end

    def normalize_bounding_box_with_offset
      @bound_model.model.bounding_box.normalize_with_offset(self)
    end

    def normalize_bounding_box
      @bound_model.model.bounding_box.normalize(self)
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
