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
      attr_reader :bounding_box, :model_has_texture, :textured_material

      attr_reader :normals_buffer, :uvs_buffer, :vertices_buffer
      attr_reader :vertices_buffer_data, :uvs_buffer_data, :normals_buffer_data

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

        # Allocate buffers for future use
        @normals_buffer, @colors_buffer, @vertices_buffer = nil
        buffer = " " * 4
        glGenBuffers(1, buffer)
        @normals_buffer = buffer.unpack('L2').first

        buffer = " " * 4
        glGenBuffers(1, buffer)
        @uvs_buffer = buffer.unpack('L2').first

        buffer = " " * 4
        glGenBuffers(1, buffer)
        @vertices_buffer = buffer.unpack('L2').first

        @bounding_box = BoundingBox.new(0,0,0, 0,0,0)
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)

        parse

        puts "#{@file_path.split('/').last} took #{((Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)-start_time)/1000.0).round(2)} seconds to parse"

        # populate_buffers

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

      def populate_buffers
        @vertices_buffer_data = @vertices.map {|vert| [vert.x, vert.y, vert.z]}.flatten.pack("f*")
        @uvs_buffer_data      = @uvs.map {|uv| [uv.x, uv.y, uv.z]}.flatten.pack("f*")
        @normals_buffer_data  = @normals.map {|norm| [norm.x, norm.y, norm.z, norm.weight]}.flatten.pack("f*")

        glBindBuffer(GL_ARRAY_BUFFER, @vertices_buffer)
        glBufferData(GL_ARRAY_BUFFER, @vertices.size, @vertices_buffer_data, GL_STATIC_DRAW)
        glBindBuffer(GL_ARRAY_BUFFER, 0)

        glBindBuffer(GL_ARRAY_BUFFER, @uvs_buffer)
        glBufferData(GL_ARRAY_BUFFER, @uvs.size, @uvs_buffer_data, GL_STATIC_DRAW)
        glBindBuffer(GL_ARRAY_BUFFER, 0)

        glBindBuffer(GL_ARRAY_BUFFER, @normals_buffer)
        glBufferData(GL_ARRAY_BUFFER, @normals.size, @normals_buffer_data, GL_STATIC_DRAW)
        glBindBuffer(GL_ARRAY_BUFFER, 0)
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
