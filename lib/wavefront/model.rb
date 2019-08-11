require_relative "parser"
require_relative "object"
require_relative "material"

class IMICFPS
  class Wavefront
    class Model
      include OpenGL
      include CommonMethods

      include Parser

      attr_accessor :objects, :materials, :vertices, :texures, :normals, :faces, :colors
      attr_accessor :scale, :entity
      attr_reader :position, :bounding_box, :textured_material

      attr_reader :vertices_buffer
      attr_reader :vertices_buffer_data
      attr_reader :vertex_array_id
      attr_reader :aabb_tree

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
        @colors   = []
        @uvs      = []
        @normals  = []
        @faces    = []
        @smoothing= 0

        @bounding_box = BoundingBox.new
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)

        parse

        puts "#{@file_path.split('/').last} took #{((Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)-start_time)/1000.0).round(2)} seconds to parse" if $debug.get(:stats)

        allocate_gl_objects
        populate_buffers
        # populate_arrays

        @objects.each {|o| @vertex_count+=o.vertices.size}
        @objects.each_with_index do |o, i|
          puts "    Model::Object Name: #{o.name}, Vertices: #{o.vertices.size}" if $debug.get(:stats)
        end
        window.number_of_vertices+=@vertex_count
        @has_texture = false
        @materials.each do |key, material|
          if material.texture_id
            @has_texture = true
            @textured_material = key
          end
        end

        build_collision_tree
      end

      def allocate_gl_objects
        # Allocate arrays for future use
        @vertex_array_id = nil
        buffer = " " * 4

        glGenVertexArrays(1, buffer)
        @vertex_array_id = buffer.unpack('L2').first

        # Allocate buffers for future use
        @vertices_buffer = nil
        buffer = " " * 4

        glGenBuffers(1, buffer)
        @vertices_buffer = buffer.unpack('L2').first
      end

      def populate_buffers
        @vertices_buffer_data = []

        verts   = []
        colors  = []
        norms   = []
        uvs     = []
        tex_ids = []

        @faces.each do |face|
          verts   << face.vertices.map    { |vert| [vert.x, vert.y, vert.z] }
          colors  << face.colors.map   { |vert| [vert.x, vert.y, vert.z] }
          norms   << face.normals.map  { |vert| [vert.x, vert.y, vert.z, vert.weight] }
          uvs     << face.uvs.map      { |vert| [vert.x, vert.y, vert.z] } if face.material.texture_id
          tex_ids << face.material.texture_id if face.material.texture_id
        end

        verts.each_with_index do |vert, i|
          @vertices_buffer_data << vert
          @vertices_buffer_data << colors[i]
          @vertices_buffer_data << norms[i]
          @vertices_buffer_data << uvs[i] if uvs.size > 0
          @vertices_buffer_data << tex_ids[i] if tex_ids.size > 0
        end

        data = @vertices_buffer_data.flatten.pack("f*")

        glBindBuffer(GL_ARRAY_BUFFER, @vertices_buffer)
        glBufferData(GL_ARRAY_BUFFER, Fiddle::SIZEOF_FLOAT * @vertices_buffer_data.size, data, GL_STATIC_DRAW)
        glBindBuffer(GL_ARRAY_BUFFER, 0)
      end

      def populate_arrays
        glBindVertexArray(@vertex_array_id)
        glBindBuffer(GL_ARRAY_BUFFER, @vertices_buffer)
        glBindVertexArray(0)
        glBindBuffer(GL_ARRAY_BUFFER, 0)
      end

      def build_collision_tree
        @aabb_tree = AABBTree.new
        @faces.each do |face|
          box = BoundingBox.new
          box.min = face.vertices.first.dup
          box.max = face.vertices.first.dup

          face.vertices.each do |vertex|
            if vertex.sum < box.min.sum
              box.min = vertex.dup
            elsif vertex.sum > box.max.sum
              box.max = vertex.dup
            end
          end

          # FIXME: Handle negatives
          box.min -= Vector.new(-0.1, -0.1, -0.1)
          box.max += Vector.new( 0.1,  0.1,  0.1)
          @aabb_tree.insert(face, box)
        end
        puts @aabb_tree.inspect if $debug.get(:stats)
      end

      def update
        @position = @entity.position
        @scale = @entity.scale
      end

      def has_texture?
        @has_texture
      end
    end
  end
end
