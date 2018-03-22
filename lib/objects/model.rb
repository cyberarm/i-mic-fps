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
    attr_reader :model, :name, :debug_color

    def initialize(type:, file_path:, x: 0, y: 0, z: 0, scale: MODEL_METER_SCALE, backface_culling: true, auto_manage: true)
      @type = type
      @file_path = file_path
      @x,@y,@z,@scale = x,y,z,scale
      @backface_culling = backface_culling
      @visible = true
      @renderable = true
      @x_rotation,@y_rotation,@z_rotation = 0,0,0
      @name = file_path.split("/").last.split(".").first
      @debug_color  = Color.new(rand(0.0..1.0), rand(0.0..1.0), rand(0.0..1.0))

      @model = nil

      unless load_model_from_cache
        case type
        when :obj
          @model = Wavefront::Model.new(file_path: @file_path, x: x, y: y, z: z, scale: scale)
        else
          raise "Unsupported model type, supported models are: #{Model.supported_models.join(', ')}"
        end

        cache_model
      end


      ObjectManager.add_object(self) if auto_manage

      setup

      return self
    end

    def setup
    end

    def draw
      handleGlError

      glEnable(GL_NORMALIZE)
      glPushMatrix
      # Render bounding boxes before transformation is applied
      render_bounding_box(@model.bounding_box) if $debug
      # @model.objects.each {|o| render_bounding_box(o.bounding_box, o.debug_color)} if $debug

      # glTranslatef(@x, @y, @z)
      # glRotatef(@x_rotation,1.0, 0, 0)
      # glRotatef(@y_rotation,0, 1.0, 0)
      # glRotatef(@z_rotation,0, 0, 1.0)

      handleGlError
      @model.draw(@x, @y, @z, @scale, @backface_culling)
      handleGlError

      glPopMatrix
      handleGlError
    end

    def update
      ObjectManager.objects.each do |b|
        next if b.name == self.name
        raise if b.name == self.name

        if self.intersect(self.model.bounding_box, b.model.bounding_box)
          self.y_rotation+=0.02

          puts "#{b.name} is touching #{self.name}"
          a_box = normalize_bounding_box(self.model.bounding_box).to_a.map {|q| q.round(2)}
          puts "(#{self.name}): (#{a_box[0..2].join(',')}) and (#{a_box[3..5].join(',')})"

          b_box = normalize_bounding_box(b.model.bounding_box).to_a.map {|q| q.round(2)}
          puts "(#{b.name}): (#{b_box[0..2].join(',')}) and (#{b_box[3..5].join(',')})"
        else
          # puts "!=! No Collision"
        end
      end
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

    # Do two Axis Aligned Bounding Boxes intersect?
    def intersect(a, b)
      a = normalize_bounding_box(a)
      b = normalize_bounding_box(b)

      puts "bounding boxes match!" if a == b
      # p to_abs(a),to_abs(b)
      # exit
      # puts "MAX_X"
      # return false if a.max_x <= b.min_x
      # puts "MIN_X"
      # return false if a.min_x >= b.max_x
      #
      # puts "MAX_Y"
      # return false if a.max_y <= b.min_y
      # puts "MIN_Y"
      # return false if a.min_y >= b.max_y
      #
      # puts "MAX_Z"
      # return false if a.max_z <= b.min_z
      # puts "MIN_Z"
      # return false if a.min_z >= b.max_z
      # puts "END"
      # return true
      # if (((a.min_x <= b.min_x && b.max_x <= a.max_x) || (b.min_x <= a.min_x && a.min_x <= b.max_x)) &&
      #     ((a.min_y <= b.min_y && b.max_y <= a.max_y) || (b.min_y <= a.min_y && a.min_y <= b.max_y)) &&
      #     ((a.min_z <= b.min_z && b.max_z <= a.max_z) || (b.min_z <= a.min_z && a.min_z <= b.max_z)))
      if (a.max_x >= b.max_x && a.min_x <= b.max_x) && (a.max_y >= b.min_y && a.min_y <= b.max_y)  && (a.max_z >= b.min_z && a.min_z <= b.max_z)
        return true
      # elsif (b.max_x >= a.max_x && b.min_x <= a.max_x) && (b.max_y >= a.min_y && b.min_y <= a.max_y)  && (b.max_z >= a.min_z && b.min_z <= a.max_z)
      #   return true
      end
    end

    def to_abs(box)
      temp = BoundingBox.new
      temp.min_x = box.min_x.abs
      temp.min_y = box.min_y.abs
      temp.min_z = box.min_z.abs

      temp.max_x = box.max_x.abs
      temp.max_y = box.max_y.abs
      temp.max_z = box.max_z.abs
      return temp
    end

    def normalize_bounding_box(box)
      temp = BoundingBox.new
      temp.min_x = box.min_x.to_f*scale+x
      temp.min_y = box.min_y.to_f*scale+y
      temp.min_z = box.min_z.to_f*scale+z

      temp.max_x = box.max_x.to_f*scale+x
      temp.max_y = box.max_y.to_f*scale+y
      temp.max_z = box.max_z.to_f*scale+z

      # puts "b: #{box}, Temp: #{temp}"
      return temp
    end

    def render_bounding_box(box, color = @debug_color)
     # TODO: Minimize number of calls in here
      box = normalize_bounding_box(box)

      glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
      # glBegin(GL_LINES)
      #   glColor3f(0,0,1.0)
      #   glVertex3f(box.min_x, box.min_y, box.min_z)
      #   glColor3f(1.0,0,0)
      #   glVertex3f(box.max_x, box.max_y, box.max_z)
      # glEnd
      glBegin(GL_TRIANGLES)
        # TOP
        glNormal3f(0,1,0)
        glColor3f(color.red, color.green, color.blue)
        glVertex3f(box.min_x, box.max_y, box.max_z)
        glVertex3f(box.min_x, box.max_y, box.min_z)
        glVertex3f(box.max_x, box.max_y, box.min_z)

        glVertex3f(box.min_x, box.max_y, box.max_z)
        glVertex3f(box.max_x, box.max_y, box.max_z)
        glVertex3f(box.max_x, box.max_y, box.min_z)

        # BOTTOM
        glNormal3f(0,-1,0)
        glVertex3f(box.max_x, box.min_y, box.min_z)
        glVertex3f(box.max_x, box.min_y, box.max_z)
        glVertex3f(box.min_x, box.min_y, box.max_z)

        glVertex3f(box.max_x, box.min_y, box.min_z)
        glVertex3f(box.min_x, box.min_y, box.min_z)
        glVertex3f(box.min_x, box.min_y, box.max_z)

        # RIGHT SIDE
        glNormal3f(0,0,1)
        glVertex3f(box.min_x, box.max_y, box.max_z)
        glVertex3f(box.min_x, box.max_y, box.min_z)
        glVertex3f(box.min_x, box.min_y, box.min_z)

        glVertex3f(box.min_x, box.min_y, box.max_z)
        glVertex3f(box.min_x, box.min_y, box.min_z)
        glVertex3f(box.min_x, box.max_y, box.max_z)

        # LEFT SIDE
        glNormal3f(1,0,0)
        glVertex3f(box.max_x, box.max_y, box.max_z)
        glVertex3f(box.max_x, box.max_y, box.min_z)
        glVertex3f(box.max_x, box.min_y, box.min_z)

        glVertex3f(box.max_x, box.min_y, box.max_z)
        glVertex3f(box.max_x, box.min_y, box.min_z)
        glVertex3f(box.max_x, box.max_y, box.max_z)

        # FRONT
        glNormal3f(-1,0,0)
        glVertex3f(box.min_x, box.max_y, box.max_z)
        glVertex3f(box.max_x, box.max_y, box.max_z)
        glVertex3f(box.max_x, box.min_y, box.max_z)

        glVertex3f(box.min_x, box.max_y, box.max_z)
        glVertex3f(box.max_x, box.min_y, box.max_z)
        glVertex3f(box.min_x, box.min_y, box.max_z)

        # BACK
        glNormal3f(-1,0,0)
        glVertex3f(box.max_x, box.min_y, box.min_z)
        glVertex3f(box.min_x, box.min_y, box.min_z)
        glVertex3f(box.min_x, box.max_y, box.min_z)

        glVertex3f(box.max_x, box.min_y, box.min_z)
        glVertex3f(box.min_x, box.max_y, box.min_z)
        glVertex3f(box.max_x, box.max_y, box.min_z)
      glEnd
      glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
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
