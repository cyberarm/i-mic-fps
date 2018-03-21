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

    def initialize(type:, file_path:, x: 0, y: 0, z: 0, scale: MODEL_METER_SCALE, backface_culling: true)
      @type = type
      @file_path = file_path
      @x,@y,@z,@scale = x,y,z,scale
      @backface_culling = backface_culling
      @visible = true
      @renderable = true
      @x_rotation,@y_rotation,@z_rotation = 0,0,0
      @name = file_path.split("/").last.split(".").first
      @debug_color  = Color.new(rand(0.0..1.0), rand(0.0..1.0), rand(0.0..1.0))
      @temp_bounding_box = BoundingBox.new(0,0,0, 0,0,0)

      @model = nil

      unless load_model_from_cache
        case type
        when :obj
          @model = Wavefront::Model.new(@file_path)
        else
          raise "Unsupported model type, supported models are: #{Model.supported_models.join(', ')}"
        end

        cache_model
      end


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
      # Render bounding boxes before transformation is applied
      render_bounding_box(@model.bounding_box) if $debug
      @model.objects.each {|o| render_bounding_box(o.bounding_box, o.debug_color)} if $debug

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
      ObjectManager.objects.each do |a|
        ObjectManager.objects.each do |b|
          next if a == b
          if a.intersect(a.model.bounding_box, b.model.bounding_box)
            if a.name == "tree"
              a.y_rotation+=0.01
            end
          end
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
     if (a.min_x <= b.max_x && a.max_x >= b.min_x) &&
        (a.min_y <= b.max_y && a.max_y >= b.min_y) &&
        (a.min_z <= b.max_z && a.max_z >= b.min_z)
       true
     else
       false
     end
   end

   def normalize_bounding_box(bounding_box)
     @temp_bounding_box.min_x = bounding_box.min_x*scale+x
     @temp_bounding_box.min_y = bounding_box.min_y*scale+y
     @temp_bounding_box.min_z = bounding_box.min_z*scale+z

     @temp_bounding_box.max_x = bounding_box.max_x*scale+x
     @temp_bounding_box.max_y = bounding_box.max_y*scale+y
     @temp_bounding_box.max_z = bounding_box.max_z*scale+z
     return @temp_bounding_box
   end

   def render_bounding_box(bounding_box, color = @debug_color)
     # TODO: Minimize number of calls in here
     bounding_box = normalize_bounding_box(bounding_box)

     glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
     glBegin(GL_TRIANGLES)
       # TOP
       glNormal3f(0,1,0)
       glColor3f(color.red, color.green, color.blue)
       glVertex3f(bounding_box.min_x, bounding_box.max_y, bounding_box.max_z)
       glVertex3f(bounding_box.min_x, bounding_box.max_y, bounding_box.min_z)
       glVertex3f(bounding_box.max_x, bounding_box.max_y, bounding_box.min_z)

       glVertex3f(bounding_box.min_x, bounding_box.max_y, bounding_box.max_z)
       glVertex3f(bounding_box.max_x, bounding_box.max_y, bounding_box.max_z)
       glVertex3f(bounding_box.max_x, bounding_box.max_y, bounding_box.min_z)

       # BOTTOM
       glNormal3f(0,-1,0)
       glVertex3f(bounding_box.max_x, bounding_box.min_y, bounding_box.min_z)
       glVertex3f(bounding_box.max_x, bounding_box.min_y, bounding_box.max_z)
       glVertex3f(bounding_box.min_x, bounding_box.min_y, bounding_box.max_z)

       glVertex3f(bounding_box.max_x, bounding_box.min_y, bounding_box.min_z)
       glVertex3f(bounding_box.min_x, bounding_box.min_y, bounding_box.min_z)
       glVertex3f(bounding_box.min_x, bounding_box.min_y, bounding_box.max_z)

       # RIGHT SIDE
       glNormal3f(0,0,1)
       glVertex3f(bounding_box.min_x, bounding_box.max_y, bounding_box.max_z)
       glVertex3f(bounding_box.min_x, bounding_box.max_y, bounding_box.min_z)
       glVertex3f(bounding_box.min_x, bounding_box.min_y, bounding_box.min_z)

       glVertex3f(bounding_box.min_x, bounding_box.min_y, bounding_box.max_z)
       glVertex3f(bounding_box.min_x, bounding_box.min_y, bounding_box.min_z)
       glVertex3f(bounding_box.min_x, bounding_box.max_y, bounding_box.max_z)

       # LEFT SIDE
       glNormal3f(1,0,0)
       glVertex3f(bounding_box.max_x, bounding_box.max_y, bounding_box.max_z)
       glVertex3f(bounding_box.max_x, bounding_box.max_y, bounding_box.min_z)
       glVertex3f(bounding_box.max_x, bounding_box.min_y, bounding_box.min_z)

       glVertex3f(bounding_box.max_x, bounding_box.min_y, bounding_box.max_z)
       glVertex3f(bounding_box.max_x, bounding_box.min_y, bounding_box.min_z)
       glVertex3f(bounding_box.max_x, bounding_box.max_y, bounding_box.max_z)

       # FRONT
       glNormal3f(-1,0,0)
       glVertex3f(bounding_box.min_x, bounding_box.max_y, bounding_box.max_z)
       glVertex3f(bounding_box.max_x, bounding_box.max_y, bounding_box.max_z)
       glVertex3f(bounding_box.max_x, bounding_box.min_y, bounding_box.max_z)

       glVertex3f(bounding_box.min_x, bounding_box.max_y, bounding_box.max_z)
       glVertex3f(bounding_box.max_x, bounding_box.min_y, bounding_box.max_z)
       glVertex3f(bounding_box.min_x, bounding_box.min_y, bounding_box.max_z)

       # BACK
       glNormal3f(-1,0,0)
       glVertex3f(bounding_box.max_x, bounding_box.min_y, bounding_box.min_z)
       glVertex3f(bounding_box.min_x, bounding_box.min_y, bounding_box.min_z)
       glVertex3f(bounding_box.min_x, bounding_box.max_y, bounding_box.min_z)

       glVertex3f(bounding_box.max_x, bounding_box.min_y, bounding_box.min_z)
       glVertex3f(bounding_box.min_x, bounding_box.max_y, bounding_box.min_z)
       glVertex3f(bounding_box.max_x, bounding_box.max_y, bounding_box.min_z)
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
