class IMICFPS
  class BoundingBoxRenderer
    include OpenGL
    include GLU

    attr_reader :bounding_boxes, :vertex_count
    def initialize
      @bounding_boxes = {}
      @vertex_count = 0
    end

    def handleGlError
      e = glGetError()
      if e != GL_NO_ERROR
        $stderr.puts "OpenGL error in: #{gluErrorString(e)} (#{e})\n"
        exit
      end
    end

    def create_bounding_box(object, box, color = nil, mesh_object_id)

      color ||= object.debug_color

      if @bounding_boxes[mesh_object_id]
        if @bounding_boxes[mesh_object_id][:color] != color
          @bounding_boxes[mesh_object_id][:colors] = mesh_colors(color).pack("f*")
          @bounding_boxes[mesh_object_id][:color]  = color
          return
        else
          return
        end
      end
      @bounding_boxes[mesh_object_id] = {}
      @bounding_boxes[mesh_object_id] = {object: object, box: box, color: color, objects: []}

      box = object.normalize_bounding_box(box)

      normals  = mesh_normals
      colors   = mesh_colors(color)
      vertices = mesh_vertices(box)

      @vertex_count+=vertices.size

      @bounding_boxes[mesh_object_id][:vertices_size] = vertices.size
      @bounding_boxes[mesh_object_id][:vertices]      = vertices.pack("f*")
      @bounding_boxes[mesh_object_id][:normals]       = normals.pack("f*")
      @bounding_boxes[mesh_object_id][:colors]        = colors.pack("f*")

      object.model.objects.each do |mesh|
        data = {}
        box = object.normalize_bounding_box(mesh.bounding_box)

        normals  = mesh_normals
        colors   = mesh_colors(mesh.debug_color)
        vertices = mesh_vertices(box)

        @vertex_count+=vertices.size

        data[:vertices_size] = vertices.size
        data[:vertices]      = vertices.pack("f*")
        data[:normals]       = normals.pack("f*")
        data[:colors]        = colors.pack("f*")

        @bounding_boxes[mesh_object_id][:objects] << data
      end
    end

    def mesh_normals
      [
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
    end

    def mesh_colors(color)
      [
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
    end

    def mesh_vertices(box)
      [
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
      @bounding_boxes.each do |key, bounding_box|
        glPushMatrix

        glTranslatef(bounding_box[:object].x, bounding_box[:object].y, bounding_box[:object].z)
        draw_bounding_box(bounding_box)
        @bounding_boxes[key][:objects].each {|o| draw_bounding_box(o)}

        glPopMatrix

        found = ObjectManager.objects.detect { |o| o == bounding_box[:object] }

        unless found
          @vertex_count -= @bounding_boxes[key][:vertices_size]
          @bounding_boxes[key][:objects].each {|o| @vertex_count -= [:vertex_count]}
          @bounding_boxes.delete(key)
        end
      end
    end

    def draw_bounding_box(bounding_box)
      glEnableClientState(GL_VERTEX_ARRAY)
      glEnableClientState(GL_COLOR_ARRAY)
      glEnableClientState(GL_NORMAL_ARRAY)

      glVertexPointer(3, GL_FLOAT, 0, bounding_box[:vertices])
      glColorPointer(3, GL_FLOAT, 0, bounding_box[:colors])
      glNormalPointer(GL_FLOAT, 0, bounding_box[:normals])

      glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
      glDisable(GL_LIGHTING)
      glDrawArrays(GL_TRIANGLES, 0, bounding_box[:vertices_size]/3)
      glEnable(GL_LIGHTING)
      glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)

      glDisableClientState(GL_VERTEX_ARRAY)
      glDisableClientState(GL_COLOR_ARRAY)
      glDisableClientState(GL_NORMAL_ARRAY)
    end
  end
end
