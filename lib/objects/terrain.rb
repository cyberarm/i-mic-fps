class IMICFPS
  class Terrain
    TILE_SIZE = 0.5
    include OpenGL
    def initialize(size:, height: nil, width: nil, length: nil, heightmap: nil)
      @size = size
      @heightmap = heightmap
      @map = []

      @height  = height ? height : 1
      @width  = width ? width : @size
      @length = length ? length : @size

      @vertices = []
      @normals  = []
      @colors   = []
      generate
    end

    def generate
      @width.times do |x|
        @length.times do |z|
          # TRIANGLE STRIP (BROKEN)
          # @map << Vertex.new((x+1)-@width.to_f/2, 0, z-@legth.to_f/2)
          # @map << Vertex.new(x-@width.to_f/2, 0, (z+1)-@length.to_f/2)

          # WORKING TRIANGLES
          @map << Vertex.new(x-@width.to_f/2, @height, z-@length.to_f/2)
          @map << Vertex.new((x+1)-@width.to_f/2, @height, z-@length.to_f/2)
          @map << Vertex.new(x-@width.to_f/2, @height, (z+1)-@length.to_f/2)

          @map << Vertex.new(x-@width.to_f/2, @height, (z+1)-@length.to_f/2)
          @map << Vertex.new((x+1)-@width.to_f/2, @height, z-@length.to_f/2)
          @map << Vertex.new((x+1)-@width.to_f/2, @height, (z+1)-@length.to_f/2)
        end
      end

      @map.size.times do |i|
        @vertices << @map[i].x
        @vertices << @map[i].y
        @vertices << @map[i].z
        normal = Vertex.new(0,1,0)
        @normals << normal.x
        @normals << normal.y
        @normals << normal.z
        color = Color.new(0,rand(0.2..1.0),0)
        @colors << color.red
        @colors << color.green
        @colors << color.blue
      end

      @vertices_packed = @vertices.pack("f*")
      @normals_packed  = @normals.pack("f*")
      @colors_packed   = @colors.pack("f*")
    end

    def draw
      new_draw
      # old_draw
    end

    def old_draw
      glEnable(GL_COLOR_MATERIAL)

      # glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
      glPointSize(5)
      # glBegin(GL_LINES)
      # glBegin(GL_POINTS)
      glBegin(GL_TRIANGLES)
        @map.each_with_index do |vertex, index|
          glNormal3f(0,1,0)
          glColor3f(0.0, 0.5, 0) if index.even?
          glColor3f(0, 1.0, 0) if index.odd?
          glVertex3f(vertex.x, vertex.y, vertex.z)
        end
      glEnd

      glDisable(GL_COLOR_MATERIAL)
      glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
    end

    def new_draw
      glEnable(GL_NORMALIZE)
      glPushMatrix

      glEnable(GL_COLOR_MATERIAL)
      glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)
      glShadeModel(GL_FLAT)
      glEnableClientState(GL_VERTEX_ARRAY)
      glEnableClientState(GL_NORMAL_ARRAY)
      glEnableClientState(GL_COLOR_ARRAY)

      glVertexPointer(3, GL_FLOAT, 0, @vertices_packed)
      glNormalPointer(GL_FLOAT, 0, @normals_packed)
      glColorPointer(3, GL_FLOAT, 0, @colors_packed)

      glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
      # glDrawArrays(GL_TRIANGLE_STRIP, 0, @vertices.size/3)
      glDrawArrays(GL_TRIANGLES, 0, @vertices.size/3)
      glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
      # glDrawArrays(GL_TRIANGLE_STRIP, 0, @vertices.size/3)
      glDrawArrays(GL_TRIANGLES, 0, @vertices.size/3)
      $window.number_of_faces+=@vertices.size/3

      glDisableClientState(GL_VERTEX_ARRAY)
      glDisableClientState(GL_NORMAL_ARRAY)
      glDisableClientState(GL_COLOR_ARRAY)

      glPopMatrix
    end
  end
end
