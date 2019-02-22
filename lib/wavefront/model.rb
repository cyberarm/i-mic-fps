require_relative "parser"
require_relative "object"
require_relative "material"

class IMICFPS
  class Wavefront
    class Model
      include OpenGL
      include CommonMethods

      include Parser

      attr_accessor :objects, :materials, :vertices, :texures, :normals, :faces
      attr_accessor :scale, :entity
      attr_reader :position, :bounding_box, :model_has_texture, :textured_material

      attr_reader :normals_buffer, :uvs_buffer, :vertices_buffer
      attr_reader :vertices_buffer_data, :uvs_buffer_data, :normals_buffer_data
      attr_reader :vertex_array_id

      def initialize(file_path:, entity: nil)
        @entity = entity
        update if @entity
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

        puts "#{@file_path.split('/').last} took #{((Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)-start_time)/1000.0).round(2)} seconds to parse" if $debug

        allocate_gl_objects
        populate_buffers
        populate_arrays

        @objects.each {|o| @vertex_count+=o.vertices.size}
        @objects.each_with_index do |o, i|
          puts "    Model::Object Name: #{o.name}, Vertices: #{o.vertices.size}" if $debug
        end
        window.number_of_vertices+=@vertex_count
        @model_has_texture = false
        @materials.each do |key, material|
          if material.texture_id
            @model_has_texture = true
            @textured_material = key
          end
        end
      end

      def allocate_gl_objects
        # Allocate arrays for future use
        @vertex_array_id = nil
        buffer = " " * 4
        glGenVertexArrays(1, buffer)
        @vertex_array_id = buffer.unpack('L2').first

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
      end

      def populate_buffers
        @vertices_buffer_data = @vertices.map {|vert| [vert.x, vert.y, vert.z]}.flatten.pack("f*")
        @uvs_buffer_data      = @uvs.map {|uv| [uv.x, uv.y, uv.z]}.flatten.pack("f*")
        @normals_buffer_data  = @normals.map {|norm| [norm.x, norm.y, norm.z, norm.weight]}.flatten.pack("f*")

        glBindBuffer(GL_ARRAY_BUFFER, @vertices_buffer)
        glBufferData(GL_ARRAY_BUFFER, Fiddle::SIZEOF_FLOAT * @vertices.size, @vertices_buffer_data, GL_STATIC_DRAW)
        glBindBuffer(GL_ARRAY_BUFFER, 0)

        glBindBuffer(GL_ARRAY_BUFFER, @uvs_buffer)
        glBufferData(GL_ARRAY_BUFFER, @uvs.size, @uvs_buffer_data, GL_STATIC_DRAW)
        glBindBuffer(GL_ARRAY_BUFFER, 0)

        glBindBuffer(GL_ARRAY_BUFFER, @normals_buffer)
        glBufferData(GL_ARRAY_BUFFER, @normals.size, @normals_buffer_data, GL_STATIC_DRAW)
        glBindBuffer(GL_ARRAY_BUFFER, 0)
      end

      def populate_arrays
        glBindVertexArray(@vertex_array_id)
        glBindBuffer(GL_ARRAY_BUFFER, @vertices_buffer)
        glBindVertexArray(0)
        glBindBuffer(GL_ARRAY_BUFFER, 0)
      end

      def update
        @position = @entity.position
        @scale = @entity.scale
        # if @scale != @entity.scale
        #   puts "oops for #{self}: #{@scale} != #{@entity.scale}"
        #   self.objects.each(&:reflatten) if self.objects && self.objects.count > 0
        # end
      end
    end
  end
end
