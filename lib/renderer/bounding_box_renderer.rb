class IMICFPS
  class BoundingBoxRenderer
    include OpenGL
    include GLU

    attr_reader :bounding_boxes
    def initialize
      @bounding_boxes = {normals: [], colors: [], vertices: []}
    end

    def handleGlError
      e = glGetError()
      if e != GL_NO_ERROR
        $stderr.puts "OpenGL error in: #{gluErrorString(e)} (#{e})\n"
        exit
      end
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
  end
end