# frozen_string_literal: true
class IMICFPS


  # A game object is any renderable thing
  class Entity
    include CommonMethods

    attr_accessor :visible, :renderable, :backface_culling
    attr_accessor :position, :orientation, :scale, :velocity
    attr_reader :name, :debug_color, :bounding_box, :drag, :camera, :manifest, :model

    def initialize(manifest:, map_entity: nil, spawnpoint: nil, backface_culling: true, run_scripts: true)
      @manifest = manifest

      if map_entity
        @position = map_entity.position.clone
        @orientation = map_entity.orientation.clone
        @scale = map_entity.scale.clone
        bind_model
      elsif spawnpoint
        @position = spawnpoint.position.clone
        @orientation = spawnpoint.orientation.clone
        @scale = Vector.new(1, 1, 1)
      else
        @position = Vector.new
        @orientation = Vector.up
        @scale = Vector.new(1, 1, 1)
      end

      @backface_culling = backface_culling
      @name = @manifest.name

      @visible = true
      @renderable = true

      @velocity   = Vector.new(0, 0, 0)
      @drag       = 1.0

      @debug_color = Color.new(0.0, 1.0, 0.0)

      @last_position = Vector.new(@position.x, @position.y, @position.z)

      @sandboxes = []
      load_scripts if run_scripts

      setup

      if @model
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
      @manifest.collision
    end

    def bind_model
      model = ModelCache.find_or_cache(manifest: @manifest)
      raise "model isn't a model!" unless model.is_a?(Model)

      @model = model
      @bounding_box = normalize_bounding_box_with_offset
    end

    def unbind_model
      @model = nil
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
      unless at_same_position?
        Publisher.instance.publish(:entity_moved, nil, self)
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
      @model.bounding_box.normalize_with_offset(self)
    end

    def normalize_bounding_box
      @model.bounding_box.normalize(self)
    end

    def model_matrix
      Transform.rotate_3d(@orientation) * Transform.scale_3d(@scale) * Transform.translate_3d(@position)
    end
  end
end
