class IMICFPS
  class Terrain < GameObject
    def setup
      bind_model(ModelLoader.new(type: :obj, file_path: "objects/randomish_terrain.obj", game_object: self))
      self.scale = 1
      @nearest_vertex_lookup = {}

      generate_optimized_lists
    end

    def generate_optimized_lists
      x_slot,y_slot = 0,0
      model.vertices.each do |vert|
        x_slot = vert.x.round
        y_slot = vert.y.round

        @nearest_vertex_lookup[x_slot] = {} unless @nearest_vertex_lookup[x_slot]
        @nearest_vertex_lookup[x_slot][y_slot] = [] unless @nearest_vertex_lookup[x_slot][y_slot]
        @nearest_vertex_lookup[x_slot][y_slot] << vert
      end
    end

    def height_at(vertex)
      if vert = find_nearest_vertex(vertex)
        return vert.y
      else
        -1
      end
    end

    def find_nearest_vertex(vertex)
      _canidate_for_floor = nil
      smaller_list = []
      smaller_list << @nearest_vertex_lookup.dig(vertex.x.round-1, vertex.y.round-1)
      smaller_list << @nearest_vertex_lookup.dig(vertex.x.round, vertex.y.round)
      smaller_list << @nearest_vertex_lookup.dig(vertex.x.round+1, vertex.y.round+1)
      smaller_list.flatten!

      smaller_list.each do |vert|
        next if vert.nil?
        if _canidate_for_floor
          if Gosu.distance(vertex.x, vertex.z, vert.x, vert.z) < Gosu.distance(_canidate_for_floor.x, _canidate_for_floor.z, vert.x, vert.z)
            _canidate_for_floor = vert
          end
        end

        _canidate_for_floor = vert unless _canidate_for_floor
      end

      return _canidate_for_floor
    end
  end
end
# class IMICFPS
#   class Terrain
#     TILE_SIZE = 0.5
#     include OpenGL
#     def initialize(size:, height: nil, width: nil, length: nil, heightmap: nil)
#       @size = size
#       @heightmap = heightmap
#       @map = []

#       @height  = height ? height : 1
#       @width  = width ? width : @size
#       @length = length ? length : @size

#       @vertices = []
#       @normals  = []
#       @colors   = []
#       generate
#     end

#     def generate
#       #@width.times do |x|
#       #  @length.times do |z|
#       #    # TRIANGLE STRIP (BROKEN)
#       #    @map << Vertex.new((x+1)-@width.to_f/2, 0, z-@legth.to_f/2)
#       #    @map << Vertex.new(x-@width.to_f/2, 0, (z+1)-@length.to_f/2)
#       #  end
#       #end
#       @width.times do |x|
#         @length.times do |z|
#           # WORKING TRIANGLES
#           @map << Vertex.new(x-@width.to_f/2, @height, z-@length.to_f/2)
#           @map << Vertex.new((x+1)-@width.to_f/2, @height, z-@length.to_f/2)
#           @map << Vertex.new(x-@width.to_f/2, @height, (z+1)-@length.to_f/2)
#           #
#           @map << Vertex.new(x-@width.to_f/2, @height, (z+1)-@length.to_f/2)
#           @map << Vertex.new((x+1)-@width.to_f/2, @height, z-@length.to_f/2)
#           @map << Vertex.new((x+1)-@width.to_f/2, @height, (z+1)-@length.to_f/2)
#         end
#       end

#       @map.size.times do |i|
#         @vertices << @map[i].x
#         @vertices << @map[i].y
#         @vertices << @map[i].z
#         normal = Vertex.new(0,1,0)
#         @normals << normal.x
#         @normals << normal.y
#         @normals << normal.z
#         color = Color.new(rand(0.10..0.30),0,0)
#         @colors << color.red
#         @colors << color.green
#         @colors << color.blue
#       end

#       @vertices_packed = @vertices.pack("f*")
#       @normals_packed  = @normals.pack("f*")
#       @colors_packed   = @colors.pack("f*")
#     end

#     def draw
#       new_draw
#       # old_draw
#     end

#     def old_draw
#       glEnable(GL_COLOR_MATERIAL)

#       # glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
#       glPointSize(5)
#       # glBegin(GL_LINES)
#       # glBegin(GL_POINTS)
#       glBegin(GL_TRIANGLES)
#         @map.each_with_index do |vertex, index|
#           glNormal3f(0,1,0)
#           glColor3f(0.0, 0.5, 0) if index.even?
#           glColor3f(0, 1.0, 0) if index.odd?
#           glVertex3f(vertex.x, vertex.y, vertex.z)
#         end
#       glEnd

#       glDisable(GL_COLOR_MATERIAL)
#       glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
#     end

#     def new_draw
#       glEnable(GL_NORMALIZE)
#       glPushMatrix

#       glEnable(GL_COLOR_MATERIAL)
#       glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)
#       glShadeModel(GL_FLAT)
#       glEnableClientState(GL_VERTEX_ARRAY)
#       glEnableClientState(GL_NORMAL_ARRAY)
#       glEnableClientState(GL_COLOR_ARRAY)

#       glVertexPointer(3, GL_FLOAT, 0, @vertices_packed)
#       glNormalPointer(GL_FLOAT, 0, @normals_packed)
#       glColorPointer(3, GL_FLOAT, 0, @colors_packed)

#       glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
#       glDrawArrays(GL_TRIANGLES, 0, @vertices.size/3)
#       glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)

#       # glDrawArrays(GL_TRIANGLE_STRIP, 0, @vertices.size/3)
#       $window.number_of_faces+=@vertices.size/3

#       glDisableClientState(GL_VERTEX_ARRAY)
#       glDisableClientState(GL_NORMAL_ARRAY)
#       glDisableClientState(GL_COLOR_ARRAY)

#       glPopMatrix
#     end
#   end
# end
