class IMICFPS
  class Terrain
    include OpenGL
    def initialize(size:, heightmap: nil)
      @size = size
      @heightmap = heightmap
      @map = []

      @vertices = []
      @normals  = []
      @colors   = []
      generate
    end

    def generate
      # x
      @size.times do |x|
        height = 0
        # row = []
        @size.times do |z|
          @map << Vertex.new(x, height, z)
          @map << Vertex.new(x, height, z-1)
          @map << Vertex.new(x+1, height, z-1)

          @map << Vertex.new(x, height, z)
          @map << Vertex.new(x+1, height, z)
          @map << Vertex.new(x+1, height, z-1)
          # height +=0.5
        end

        # @map << row
      end

      @map.size do |i|
        @vertices << @map[i].x
        @vertices << @map[i].y
        @vertices << @map[i].z
        @vertices << 1.0
        normal = Vertex.new(0,1,0)
        @normals << normal.x
        @normals << normal.y
        @normals << normal.z
        color = Vertex.new(0,rand(0.2..1.0),0)
        @colors << color.red
        @colors << color.green
        @colors << color.blue
      end
      @vertices = @vertices.pack("f*")
      @normals = @normals.pack("f*")
      @colors = @colors.pack("f*")
    end

    def draw
      new_draw
      old_draw
    end

    def old_draw
      height = 0
      glEnable(GL_COLOR_MATERIAL)

      glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)

          glBegin(GL_TRIANGLES)
            @map.each do |vertex|
              glNormal3f(0,1,0)
              glColor3f(0.0, 0.5, 0)
              glVertex3f(vertex.x, vertex.y, vertex.z)
            end
          glEnd

      glDisable(GL_COLOR_MATERIAL)
      glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
    end

    def new_draw
      glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
      glEnable(GL_NORMALIZE)
      glPushMatrix

      glEnable(GL_COLOR_MATERIAL)
      glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)
      glShadeModel(GL_SMOOTH)
      glEnableClientState(GL_VERTEX_ARRAY)
      glEnableClientState(GL_NORMAL_ARRAY)
      glEnableClientState(GL_COLOR_ARRAY)

      glVertexPointer(4, GL_FLOAT, 0, @vertices)
      glNormalPointer(GL_FLOAT, 0, @normals)
      glColorPointer(3, GL_FLOAT, 0, @colors)

      glDrawArrays(GL_TRIANGLES, 0, @map.size/4)

      glDisableClientState(GL_VERTEX_ARRAY)
      glDisableClientState(GL_NORMAL_ARRAY)
      glDisableClientState(GL_COLOR_ARRAY)

      glPopMatrix
      glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
    end
  end
end
