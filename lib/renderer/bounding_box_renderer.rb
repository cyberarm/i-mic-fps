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
          update_mesh_colors(mesh_object_id, color)
          return
        else
          return
        end
      end
      @bounding_boxes[mesh_object_id] = {}
      @bounding_boxes[mesh_object_id] = {object: object, box: box, color: color}

      box = object.normalize_bounding_box(box)

      update_mesh_colors(mesh_object_id, color)

      normals = [
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
      vertices = [
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

      @vertex_count+=vertices.size

      @bounding_boxes[mesh_object_id][:vertices_size] = vertices.size
      @bounding_boxes[mesh_object_id][:vertices] = vertices.pack("f*")
      @bounding_boxes[mesh_object_id][:normals] = normals.pack("f*")
    end

    def update_mesh_colors(mesh_object_id, color)
      @bounding_boxes[mesh_object_id][:colors] = [
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
      ].pack("f*")

      @bounding_boxes[mesh_object_id][:color] = color
    end

    def draw_bounding_boxes
      @bounding_boxes.each do |key, bounding_box|
        glPushMatrix

        glTranslatef(bounding_box[:object].x, bounding_box[:object].y, bounding_box[:object].z)
        draw_bounding_box(bounding_box)

        glPopMatrix

        found = ObjectManager.objects.detect { |o| o == bounding_box[:object] }
        @bounding_boxes.delete(key) unless found
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
