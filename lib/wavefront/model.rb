class IMICFPS
  class Wavefront
    class Model
      include OpenGL
      include GLU

      include Parser

      attr_accessor :objects, :materials, :vertexes, :texures, :normals, :faces
      attr_accessor :x, :y, :z

      def initialize(object = "objects/cube.obj")
        @x, @y, @z = 0, 0, 0
        @object_path = object
        @file = File.open(object, 'r')
        @material_file  = nil
        @current_object = nil
        @current_material=nil
        @vertex_count  = 0
        @objects  = []
        @materials= {}
        @vertices = []
        @uvs      = []
        @normals  = []
        @faces    = []
        @smoothing= 0

        @bounding_box = BoundingBox.new(0.0,0.0,0.0, 0.0,0.0,0.0)
        @debug_color  = Color.new(rand(0.0..1.0), rand(0.0..1.0), rand(0.0..1.0))
        start_time = Time.now
        parse
        puts "#{object.split('/').last} took #{(Time.now-start_time).round(2)} seconds to parse"
        p @bounding_box

        face_count = 0
        @objects.each {|o| face_count+=o.faces.size}
        @objects.each_with_index do |o, i|
          puts "OBJECT FACES: Name: #{o.name} #{o.faces.size}, array size divided by 3: #{o.faces.size.to_f/3.0}"
        end
        $window.number_of_faces+=face_count
        @model_has_texture = false
        @materials.each do |key, material|
          if material.texture_id
            @model_has_texture = true
            @textured_material = key
          end
        end
      end

      def handleGlError
        e = glGetError()
        if e != GL_NO_ERROR
          $stderr.puts "OpenGL error in: #{gluErrorString(e)} (#{e})\n"
          exit
        end
      end

      def draw(x, y, z, scale = MODEL_METER_SCALE, back_face_culling = true)
        handleGlError
        render(x,y,z, scale, back_face_culling)
        handleGlError
      end

      def render(x,y,z, scale, back_face_culling)
        glEnable(GL_NORMALIZE)
        glPushMatrix
        glTranslatef(x,y,z)
        glScalef(scale, scale, scale)
        @objects.each_with_index do |o, i|
          glEnable(GL_CULL_FACE) if back_face_culling
          glEnable(GL_COLOR_MATERIAL)
          glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)
          glShadeModel(GL_FLAT) unless o.faces.first[4]
          glShadeModel(GL_SMOOTH) if o.faces.first[4]
          glEnableClientState(GL_VERTEX_ARRAY)
          glEnableClientState(GL_COLOR_ARRAY)
          glEnableClientState(GL_NORMAL_ARRAY)
          if @model_has_texture
            glEnable(GL_TEXTURE_2D)
            glBindTexture(GL_TEXTURE_2D, @materials[@textured_material].texture_id)
            glEnableClientState(GL_TEXTURE_COORD_ARRAY)
            glTexCoordPointer(3, GL_FLOAT, 0, o.flattened_textures)
          end
          glVertexPointer(4, GL_FLOAT, 0, o.flattened_vertices)
          glColorPointer(3, GL_FLOAT, 0, o.flattened_materials)
          glNormalPointer(GL_FLOAT, 0, o.flattened_normals)

          glDrawArrays(GL_TRIANGLES, 0, o.flattened_vertices_size/4)

          glDisableClientState(GL_VERTEX_ARRAY)
          glDisableClientState(GL_COLOR_ARRAY)
          glDisableClientState(GL_NORMAL_ARRAY)
          if @model_has_texture
            glDisableClientState(GL_TEXTURE_COORD_ARRAY)
            # glBindTexture(GL_TEXTURE_2D, 0)
            glDisable(GL_TEXTURE_2D)
          end
          glDisable(GL_CULL_FACE) if back_face_culling
          glDisable(GL_COLOR_MATERIAL)
          render_bounding_box(o.bounding_box) if ARGV.join("--debug")
        end
        render_bounding_box(@bounding_box) if ARGV.join("--debug")
        glPopMatrix


        $window.number_of_faces+=self.faces.size
      end

      def render_bounding_box(bounding_box, color = @debug_color)
        # TODO: Minimize number of calls in here
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
    end
  end
end
