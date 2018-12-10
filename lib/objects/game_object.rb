class IMICFPS


  # A game object is any renderable thing
  class GameObject
    include OpenGL
    include GLU
    include CommonMethods
    attr_accessor :x, :y, :z, :scale
    attr_accessor :visible, :renderable, :backface_culling
    attr_accessor :x_rotation, :y_rotation, :z_rotation
    attr_reader :model, :name, :debug_color, :terrain, :width, :height, :depth
    def initialize(x: 0, y: 0, z: 0, bound_model: nil, scale: MODEL_METER_SCALE, backface_culling: true, auto_manage: true, terrain: nil)
      @x,@y,@z,@scale = x,y,z,scale
      @bound_model = bound_model
      @backface_culling = backface_culling
      @visible = true
      @renderable = true
      @x_rotation,@y_rotation,@z_rotation = 0,0,0
      @debug_color = Color.new(0.0, 1.0, 0.0)
      @terrain = terrain
      @width, @height, @depth = 0,0,0
      @delta_time = Gosu.milliseconds

      ObjectManager.add_object(self) if auto_manage
      setup

      if @bound_model
        @bound_model.model.game_object = self
        @bound_model.model.objects.each {|o| o.scale = self.scale}

        box = normalize_bounding_box(@bound_model.model.bounding_box)
        @width  = box.max_x-box.min_x
        @height = box.max_y-box.min_y
        @depth  = box.max_z-box.min_z
      end

      return self
    end

    def bind_model(model)
      raise "model isn't a model!" unless model.is_a?(ModelLoader)
      @bound_model = model
      @bound_model.model.game_object = self
      @bound_model.model.objects.each {|o| o.scale = self.scale}
      box = normalize_bounding_box(@bound_model.model.bounding_box)
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
    end

    def debug_color=(color)
      @debug_color = color
    end

    # Do two Axis Aligned Bounding Boxes intersect?
    def intersect(a, b)
      a = a.normalize_bounding_box_with_offset(a.model.bounding_box)
      b = b.normalize_bounding_box_with_offset(b.model.bounding_box)

      # puts "bounding boxes match!" if a == b
      if  (a.min_x <= b.max_x && a.max_x >= b.min_x) &&
          (a.min_y <= b.max_y && a.max_y >= b.min_y) &&
          (a.min_z <= b.max_z && a.max_z >= b.min_z)
        return true
      else
        return false
      end
    end

    def normalize_bounding_box(box)
      temp = BoundingBox.new
      temp.min_x = box.min_x.to_f*scale
      temp.min_y = box.min_y.to_f*scale
      temp.min_z = box.min_z.to_f*scale

      temp.max_x = box.max_x.to_f*scale
      temp.max_y = box.max_y.to_f*scale
      temp.max_z = box.max_z.to_f*scale

      return temp
    end

    def normalize_bounding_box_with_offset(box)
      temp = BoundingBox.new
      temp.min_x = box.min_x.to_f*scale+x
      temp.min_y = box.min_y.to_f*scale+y
      temp.min_z = box.min_z.to_f*scale+z

      temp.max_x = box.max_x.to_f*scale+x
      temp.max_y = box.max_y.to_f*scale+y
      temp.max_z = box.max_z.to_f*scale+z

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
