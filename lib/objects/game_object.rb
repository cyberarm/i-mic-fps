class IMICFPS


  # A game object is any renderable thing
  class GameObject
    include OpenGL
    include CommonMethods
    attr_accessor :x, :y, :z, :scale
    attr_accessor :visible, :renderable, :backface_culling
    attr_accessor :x_rotation, :y_rotation, :z_rotation
    attr_reader :model, :name, :debug_color
    def initialize(x: 0, y: 0, z: 0, bound_model: nil, scale: MODEL_METER_SCALE, backface_culling: true, auto_manage: true)
      @x,@y,@z,@scale = x,y,z,scale
      @bound_model = bound_model
      @backface_culling = backface_culling
      @visible = true
      @renderable = true
      @x_rotation,@y_rotation,@z_rotation = 0,0,0
      @debug_color = Color.new(0.0, 1.0, 0.0)

      ObjectManager.add_object(self) if auto_manage
      setup

      return self
    end

    def bind_model(model)
      raise "model isn't a model!" unless model.is_a?(ModelLoader)
      @bound_model = model
    end

    def model
      @bound_model.model if @bound_model
    end

    def unbind_model
      @bound_model = nil
    end

    def setup
    end

    def draw
      handleGlError

      glEnable(GL_NORMALIZE)
      glPushMatrix
      # Render bounding boxes before transformation is applied
      render_bounding_box(model.bounding_box) if $debug
      model.objects.each {|o| render_bounding_box(o.bounding_box, o.debug_color)} if $debug

      glTranslatef(@x, @y, @z)
      glRotatef(@x_rotation,1.0, 0, 0)
      glRotatef(@y_rotation,0, 1.0, 0)
      glRotatef(@z_rotation,0, 0, 1.0)

      handleGlError
      model.draw(@x, @y, @z, @scale, @backface_culling)
      handleGlError

      glPopMatrix
      handleGlError
    end

    def update
    end
    # Do two Axis Aligned Bounding Boxes intersect?
    def intersect(a, b)
      a = normalize_bounding_box(a)
      b = normalize_bounding_box(b)

      puts "bounding boxes match!" if a == b
      # if (((a.min_x <= b.min_x && b.max_x <= a.max_x) || (b.min_x <= a.min_x && a.min_x <= b.max_x)) &&
      #     ((a.min_y <= b.min_y && b.max_y <= a.max_y) || (b.min_y <= a.min_y && a.min_y <= b.max_y)) &&
      #     ((a.min_z <= b.min_z && b.max_z <= a.max_z) || (b.min_z <= a.min_z && a.min_z <= b.max_z)))
      if (a.max_x >= b.max_x && a.min_x <= b.max_x) && (a.max_y >= b.min_y && a.min_y <= b.max_y)  && (a.max_z >= b.min_z && a.min_z <= b.max_z)
        return true
      else
        return false
      end
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
