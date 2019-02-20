class IMICFPS


  # A game object is any renderable thing
  class Entity
    include OpenGL
    include GLU
    include CommonMethods
    attr_accessor :scale
    attr_accessor :visible, :renderable, :backface_culling
    attr_reader :position, :rotation, :velocity
    attr_reader :model, :name, :debug_color, :width, :height, :depth, :last_x, :last_y, :last_z, :normalized_bounding_box
    def initialize(x: 0, y: 0, z: 0, bound_model: nil, scale: MODEL_METER_SCALE, backface_culling: true, auto_manage: true, manifest_file: nil)
      @position = Vector.new(x, y, z)
      @scale = scale
      @bound_model = bound_model
      @backface_culling = backface_culling
      @visible = true
      @renderable = true
      @rotation   = Vector.new(0, 0, 0)
      @velocity   = Vector.new(0, 0, 0)

      @debug_color = Color.new(0.0, 1.0, 0.0)

      @collidable = [:static, :dynamic]
      @collision  = :static # :dynamic, moves in response, :static, does not move ever, :none, entities can pass through
      @physics    = false
      @mass       = 100 # kg

      @width, @height, @depth = 0,0,0
      @delta_time = Gosu.milliseconds
      @last_position = Vector.new(@position.x, @position.y, @position.z)

      setup

      if @bound_model
        @bound_model.model.entity = self
        @bound_model.model.objects.each {|o| o.scale = self.scale}
        @normalized_bounding_box = normalize_bounding_box_with_offset

        box = normalize_bounding_box
        @width  = box.max_x-box.min_x
        @height = box.max_y-box.min_y
        @depth  = box.max_z-box.min_z
      end

      return self
    end

    def collidable?
      @collidable.include?(@collision)
    end

    def bind_model(package, name)
      model = ModelLoader.new(manifest_file: IMICFPS.assets_path + "/#{package}/#{name}/#{name}.yaml", entity: @dummy_entity)

      raise "model isn't a model!" unless model.is_a?(ModelLoader)
      @bound_model = model
      @bound_model.model.entity = self
      @bound_model.model.objects.each {|o| o.scale = self.scale}
      @normalized_bounding_box = normalize_bounding_box_with_offset

      box = normalize_bounding_box
      @width  = box.max_x-box.min_x
      @height = box.max_y-box.min_y
      @depth  = box.max_z-box.min_z
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
        @normalized_bounding_box = normalize_bounding_box_with_offset if model
      end

      @last_x, @last_y, @last_z = @x, @y, @z
    end

    def debug_color=(color)
      @debug_color = color
    end

    def at_same_position?
      @position == @last_position
    end

    # Do two Axis Aligned Bounding Boxes intersect?
    def intersect(other)
      me = normalized_bounding_box
      other = other.normalized_bounding_box

      # puts "bounding boxes match!" if a == b
      if  (me.min_x <= other.max_x && me.max_x >= other.min_x) &&
          (me.min_y <= other.max_y && me.max_y >= other.min_y) &&
          (me.min_z <= other.max_z && me.max_z >= other.min_z)
        return true
      else
        return false
      end
    end

    def distance(vertex, other)
      return Math.sqrt((vertex.x-other.x)**2 + (vertex.y-other.y)**2 + (vertex.z-other.z)**2)
    end

    def normalize_bounding_box
      box = @bound_model.model.bounding_box

      temp = BoundingBox.new
      temp.min_x = box.min_x.to_f*scale
      temp.min_y = box.min_y.to_f*scale
      temp.min_z = box.min_z.to_f*scale

      temp.max_x = box.max_x.to_f*scale
      temp.max_y = box.max_y.to_f*scale
      temp.max_z = box.max_z.to_f*scale

      return temp
    end

    def normalize_bounding_box_with_offset
      box = @bound_model.model.bounding_box

      temp = BoundingBox.new
      temp.min_x = box.min_x.to_f*scale+@position.x
      temp.min_y = box.min_y.to_f*scale+@position.y
      temp.min_z = box.min_z.to_f*scale+@position.z

      temp.max_x = box.max_x.to_f*scale+@position.x
      temp.max_y = box.max_y.to_f*scale+@position.y
      temp.max_z = box.max_z.to_f*scale+@position.z

      return temp
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
