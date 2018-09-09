require_relative "parser"
require_relative "object"
require_relative "material"

class IMICFPS
  class Wavefront
    class Model
      include OpenGL
      # include GLU

      include Parser

      attr_accessor :objects, :materials, :vertices, :texures, :normals, :faces
      attr_accessor :x, :y, :z, :scale, :game_object
      attr_reader :bounding_box

      def initialize(file_path:, game_object: nil)
        @game_object = game_object
        update if @game_object
        @file_path = file_path
        @file = File.open(file_path, 'r')
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

        @bounding_box = BoundingBox.new(0,0,0, 0,0,0)
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
        parse
        puts "#{@file_path.split('/').last} took #{((Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)-start_time)/1000.0).round(2)} seconds to parse"

        face_count = 0
        @objects.each {|o| face_count+=o.faces.size}
        @objects.each_with_index do |o, i|
          puts "    Model::Object Name: #{o.name}, Faces: #{o.faces.size}"
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

      def draw(x,y,z, scale, back_face_culling)
        @x,@y,@z,@scale,@back_face_culling = x,y,z, scale, back_face_culling
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
          if @model_has_texture
            glDisableClientState(GL_TEXTURE_COORD_ARRAY)
            # glBindTexture(GL_TEXTURE_2D, 0)
            glDisable(GL_TEXTURE_2D)
          end
          glDisable(GL_CULL_FACE) if back_face_culling
          glDisable(GL_COLOR_MATERIAL)
        end
        $window.number_of_faces+=self.faces.size
      end

      def update
        @x, @y, @z = @game_object.x, @game_object.y, @game_object.z
        @scale = @game_object.scale
        # if @scale != @game_object.scale
        #   puts "oops for #{self}: #{@scale} != #{@game_object.scale}"
        #   self.objects.each(&:reflatten) if self.objects && self.objects.count > 0
        # end
      end
    end
  end
end
