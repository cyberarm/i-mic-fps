class IMICFPS
  class Renderer
    include OpenGL
    include GLU

    def initialize
      @bounding_boxes = {normals: [], colors: [], vertices: []}
    end

    def draw
      i = 0
      draw_bounding_boxes if $debug
      $window.number_of_faces+=@bounding_boxes[:vertices].size/3 if $debug
      @bounding_boxes.clear
      ObjectManager.objects.each do |object|
        if object.visible && object.renderable
          draw_object(object)
          i+=1
        end
      end

    end

    def draw_object(object)
      handleGlError

      glEnable(GL_NORMALIZE)
      glPushMatrix
      # Render bounding boxes before transformation is applied
      create_bounding_box(object, object.model.bounding_box) if $debug
      object.model.objects.each {|o| create_bounding_box(object, o.bounding_box, o.debug_color)} if $debug

      glTranslatef(object.x, object.y, object.z)
      glRotatef(object.x_rotation,1.0, 0, 0)
      glRotatef(object.y_rotation,0, 1.0, 0)
      glRotatef(object.z_rotation,0, 0, 1.0)

      handleGlError
      draw_mesh(object.model)
      object.draw
      # object.model.draw(object.x, object.y, object.z, object.scale, object.backface_culling)
      handleGlError

      glPopMatrix
      handleGlError
    end

    def draw_mesh(model)
      # x,y,z, scale, back_face_culling
      model.objects.each_with_index do |o, i|
        glEnable(GL_CULL_FACE) if model.game_object.backface_culling
        glEnable(GL_COLOR_MATERIAL)
        glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)
        glShadeModel(GL_FLAT) unless o.faces.first[4]
        glShadeModel(GL_SMOOTH) if o.faces.first[4]
        glEnableClientState(GL_VERTEX_ARRAY)
        glEnableClientState(GL_COLOR_ARRAY)
        glEnableClientState(GL_NORMAL_ARRAY)
        if model.model_has_texture
          glEnable(GL_TEXTURE_2D)
          glBindTexture(GL_TEXTURE_2D, model.materials[model.textured_material].texture_id)
          glEnableClientState(GL_TEXTURE_COORD_ARRAY)
          glTexCoordPointer(3, GL_FLOAT, 0, o.flattened_textures)
        end
        glVertexPointer(4, GL_FLOAT, 0, o.flattened_vertices)
        glColorPointer(3, GL_FLOAT, 0, o.flattened_materials)
        glNormalPointer(GL_FLOAT, 0, o.flattened_normals)

        glDrawArrays(GL_TRIANGLES, 0, o.flattened_vertices_size/4)

        if $debug
          glDisable(GL_LIGHTING)
          glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
          glPolygonOffset(2, 0.5)
          glLineWidth(3)
          glDrawArrays(GL_TRIANGLES, 0, o.flattened_vertices_size/4)
          glLineWidth(1)
          glPolygonOffset(0, 0)
          glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
          glEnable(GL_LIGHTING)
        end

        glDisableClientState(GL_VERTEX_ARRAY)
        glDisableClientState(GL_COLOR_ARRAY)
        glDisableClientState(GL_NORMAL_ARRAY)
        if model.model_has_texture
          glDisableClientState(GL_TEXTURE_COORD_ARRAY)
          # glBindTexture(GL_TEXTURE_2D, 0)
          glDisable(GL_TEXTURE_2D)
        end
        glDisable(GL_CULL_FACE) if model.game_object.backface_culling
        glDisable(GL_COLOR_MATERIAL)
      end
      $window.number_of_faces+=model.faces.size
    end

    def create_bounding_box(object, box, color = nil)
      color ||= object.debug_color
      box = object.normalize_bounding_box(box)

      @bounding_boxes[:normals]  ||= []
      @bounding_boxes[:colors]   ||= []
      @bounding_boxes[:vertices] ||= []

      @bounding_boxes[:normals] << [
        0,1,0,
        0,1,0,
        0,1,0,
        0,1,0,
        0,1,0,
        0,1,0,

        0,-1,0,
        0,-1,0,
        0,-1,0,
        0,-1,0,
        0,-1,0,
        0,-1,0,

        0,0,1,
        0,0,1,
        0,0,1,
        0,0,1,
        0,0,1,
        0,0,1,

        1,0,0,
        1,0,0,
        1,0,0,
        1,0,0,
        1,0,0,
        1,0,0,

        -1,0,0,
        -1,0,0,
        -1,0,0,
        -1,0,0,
        -1,0,0,
        -1,0,0,

        -1,0,0,
        -1,0,0,
        -1,0,0,

        -1,0,0,
        -1,0,0,
        -1,0,0
      ]
      @bounding_boxes[:colors] << [
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue
      ]
      @bounding_boxes[:vertices] << [
        box.min_x, box.max_y, box.max_z,
        box.min_x, box.max_y, box.min_z,
        box.max_x, box.max_y, box.min_z,

        box.min_x, box.max_y, box.max_z,
        box.max_x, box.max_y, box.max_z,
        box.max_x, box.max_y, box.min_z,

        box.max_x, box.min_y, box.min_z,
        box.max_x, box.min_y, box.max_z,
        box.min_x, box.min_y, box.max_z,

        box.max_x, box.min_y, box.min_z,
        box.min_x, box.min_y, box.min_z,
        box.min_x, box.min_y, box.max_z,

        box.min_x, box.max_y, box.max_z,
        box.min_x, box.max_y, box.min_z,
        box.min_x, box.min_y, box.min_z,

        box.min_x, box.min_y, box.max_z,
        box.min_x, box.min_y, box.min_z,
        box.min_x, box.max_y, box.max_z,

        box.max_x, box.max_y, box.max_z,
        box.max_x, box.max_y, box.min_z,
        box.max_x, box.min_y, box.min_z,

        box.max_x, box.min_y, box.max_z,
        box.max_x, box.min_y, box.min_z,
        box.max_x, box.max_y, box.max_z,

        box.min_x, box.max_y, box.max_z,
        box.max_x, box.max_y, box.max_z,
        box.max_x, box.min_y, box.max_z,

        box.min_x, box.max_y, box.max_z,
        box.max_x, box.min_y, box.max_z,
        box.min_x, box.min_y, box.max_z,

        box.max_x, box.min_y, box.min_z,
        box.min_x, box.min_y, box.min_z,
        box.min_x, box.max_y, box.min_z,

        box.max_x, box.min_y, box.min_z,
        box.min_x, box.max_y, box.min_z,
        box.max_x, box.max_y, box.min_z
      ]
    end

    def draw_bounding_boxes
      glEnableClientState(GL_VERTEX_ARRAY)
      glEnableClientState(GL_COLOR_ARRAY)
      glEnableClientState(GL_NORMAL_ARRAY)

      _normals = @bounding_boxes[:normals].flatten.pack("f*")
      _colors = @bounding_boxes[:colors].flatten.pack("f*")
      _vertices_size = @bounding_boxes[:vertices].size
      _vertices = @bounding_boxes[:vertices].flatten.pack("f*")

      glVertexPointer(3, GL_FLOAT, 0, _vertices)
      glColorPointer(3, GL_FLOAT, 0, _colors)
      glNormalPointer(GL_FLOAT, 0, _normals)

      glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
      glDisable(GL_LIGHTING)
      glDrawArrays(GL_TRIANGLES, 0, _vertices_size/3)
      glEnable(GL_LIGHTING)
      glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)

      glDisableClientState(GL_VERTEX_ARRAY)
      glDisableClientState(GL_COLOR_ARRAY)
      glDisableClientState(GL_NORMAL_ARRAY)
    end

    def handleGlError
      e = glGetError()
      if e != GL_NO_ERROR
        $stderr.puts "OpenGL error in: #{gluErrorString(e)} (#{e})\n"
        exit
      end
    end

    def finalize # cleanup
    end
  end
end