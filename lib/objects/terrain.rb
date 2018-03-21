class IMICFPS
  class Terrain
    include OpenGL
    def initialize(size:, heightmap: nil)
      @size = size
      @heightmap = heightmap
    end

    def draw
      height = 0
      glEnable(GL_COLOR_MATERIAL)

      glBegin(GL_TRIANGLES)
        glNormal3f(0,1,0)
        glColor3f(1, 0.5, 0.0)
        glVertex3f(-@size,height,-@size)
        glVertex3f(-@size,height,@size)
        glVertex3f(@size,height,@size)

        glColor3f(0, 0.5, 0.0)
        glVertex3f(@size,height,@size)
        glVertex3f(@size,height,-@size)
        glVertex3f(-@size,height,-@size)
      glEnd

      glDisable(GL_COLOR_MATERIAL)
    end
  end
end
