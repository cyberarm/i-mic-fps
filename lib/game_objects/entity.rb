class IMICFPS


  # A game object is any renderable thing
  class Entity
    include CommonMethods

    attr_accessor :scale, :visible, :renderable, :backface_culling
    attr_accessor :position, :orientation, :velocity
    attr_reader :name, :debug_color, :bounding_box, :collision, :physics, :mass, :drag, :camera

    def initialize(manifest:, map_entity: nil, spawnpoint: nil, backface_culling: true, auto_manage: true)
      @manifest = manifest
      @position = map_entity ? map_entity.position.clone : spawnpoint.position.clone
      @orientation = map_entity ? map_entity.orientation.clone : spawnpoint.orientation.clone
      @scale = map_entity ? map_entity.scale.clone : Vector.new(1, 1, 1)

      @backface_culling = backface_culling
      @name = @manifest.name
      @bound_model = map_entity ? bind_model : nil

      @visible = true
      @renderable = true

      @velocity   = Vector.new(0, 0, 0)
      @drag       = 1.0

      @debug_color = Color.new(0.0, 1.0, 0.0)

      @collidable = [:static, :dynamic]
      # :dynamic => moves in response,
      # :static => does not move ever,
      # :none => no collision check, entities can pass through
      @collision  = :static
      @physics    = @manifest.physics # Entity affected by gravity and what not
      @mass       = 100 # kg

      @last_position = Vector.new(@position.x, @position.y, @position.z)

      @sandboxes = []
      load_scripts

      setup

      if @bound_model
        @bound_model.model.entity = self
        @normalized_bounding_box = normalize_bounding_box_with_offset

        normalize_bounding_box
      end

      @camera = nil

      return self
    end

    def load_scripts
      @manifest.scripts.each do |script|
        @sandboxes << Scripting::SandBox.new(entity: self, script: script)
      end
    end

    def collidable?
      @collidable.include?(@collision)
    end

    def bind_model
      model = ModelLoader.new(manifest: @manifest, entity: @dummy_entity)

      raise "model isn't a model!" unless model.is_a?(ModelLoader)
      @bound_model = model
      @bound_model.model.entity = self
      @bounding_box = normalize_bounding_box_with_offset

      return model
    end

    def model
      @bound_model.model if @bound_model
    end

    def unbind_model
      @bound_model = nil
    end

    def attach_camera(camera)
      @camera = camera
    end

    def detach_camera
      @camera = nil
    end

    def setup
    end

    # Not advisable to put OpenGL code here, instead put it in Renderer.
    def draw
    end


    def update
      model.update

      unless at_same_position?
        Publisher.instance.publish(:entity_moved, self, self)
        @bounding_box = normalize_bounding_box_with_offset if model
      end

      @last_position = Vector.new(@position.x, @position.y, @position.z)
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
  end
end
