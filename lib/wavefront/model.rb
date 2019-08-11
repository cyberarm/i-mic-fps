require_relative "parser"
require_relative "object"
require_relative "material"

class IMICFPS
  class Wavefront
    class Model
      include CommonMethods

      include Parser

      attr_accessor :objects, :materials, :vertices, :texures, :normals, :faces, :colors
      attr_accessor :scale, :entity
      attr_reader :position, :bounding_box, :textured_material

      attr_reader :vertices_buffer_id
      attr_reader :vertices_buffer_data
      attr_reader :vertices_buffer_size
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
        populate_vertex_buffer
        configure_vao

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

        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
        build_collision_tree
        puts "    Building mesh collision tree took #{((Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)-start_time)/1000.0).round(2)} seconds" if $debug.get(:stats)
      end

      def allocate_gl_objects
        # Allocate arrays for future use
        @vertex_array_id = nil
        buffer = " " * 4

        glGenVertexArrays(1, buffer)
        @vertex_array_id = buffer.unpack('L2').first

        # Allocate buffers for future use
        @vertices_buffer_id = nil
        buffer = " " * 4

        glGenBuffers(1, buffer)
        @vertices_buffer_id = buffer.unpack('L2').first
      end

      def populate_vertex_buffer
        @vertices_buffer_size = 0
        @vertices_buffer_data = []
        model_has_texture = @materials.any? { |id, mat| mat.texture_id != nil }

        verts   = []
        colors  = []
        norms   = []
        uvs     = []
        tex_ids = []

        @faces.each do |face|
          verts   << face.vertices.map    { |vert| [vert.x, vert.y, vert.z] }
          colors  << face.colors.map   { |vert| [vert.x, vert.y, vert.z] }
          norms   << face.normals.map  { |vert| [vert.x, vert.y, vert.z, vert.weight] }

          if model_has_texture
            uvs     << face.uvs.map      { |vert| [vert.x, vert.y, vert.z] }
            tex_ids << face.material.texture_id ? face.material.texture_id : -1
          end
        end

        verts.each_with_index do |vert, i|
          @vertices_buffer_data << vert
          @vertices_buffer_data << colors[i]
          @vertices_buffer_data << norms[i]
          @vertices_buffer_data << uvs[i] if uvs.size > 0
          @vertices_buffer_data << tex_ids[i] if tex_ids.size > 0
        end

        data_size = 0
        data_size += Fiddle::SIZEOF_FLOAT * 3 * verts.size
        data_size += Fiddle::SIZEOF_FLOAT * 3 * colors.size
        data_size += Fiddle::SIZEOF_FLOAT * 4 * norms.size
        data_size += Fiddle::SIZEOF_FLOAT * 3 * uvs.size
        data_size += Fiddle::SIZEOF_INT * 1 * tex_ids.size

        @vertices_buffer_size = data_size

        data = @vertices_buffer_data.flatten.pack("f*")

        glBindBuffer(GL_ARRAY_BUFFER, @vertices_buffer_id)
        glBufferData(GL_ARRAY_BUFFER, @vertices_buffer_size, data, GL_STATIC_DRAW)
        glBindBuffer(GL_ARRAY_BUFFER, 0)
      end

      def configure_vao
        glBindBuffer(GL_ARRAY_BUFFER, @vertices_buffer_id)
        glBindVertexArray(@vertex_array_id)

        glEnableVertexAttribArray(0)
        glEnableVertexAttribArray(1)
        glEnableVertexAttribArray(2)
        glEnableVertexAttribArray(3)
        glEnableVertexAttribArray(4)

        # index, size, type, normalized, stride, pointer
        # vertices (positions)
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, Fiddle::SIZEOF_FLOAT * 3, nil)
        handleGlError
        # colors
        glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, Fiddle::SIZEOF_FLOAT * (3 + 3), nil)
        handleGlError
        # normals
        glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, Fiddle::SIZEOF_FLOAT * (4 + 3 + 3), nil)
        handleGlError
        # uvs
        glVertexAttribPointer(3, 4, GL_FLOAT, GL_FALSE, Fiddle::SIZEOF_FLOAT * (3 + 4 + 3 + 3), nil)
        handleGlError
        # texture ids
        glVertexAttribPointer(4, 1, GL_FLOAT, GL_FALSE, Fiddle::SIZEOF_FLOAT + (Fiddle::SIZEOF_FLOAT * (3 + 4 + 3 + 3)), nil)
        handleGlError

        glDisableVertexAttribArray(4)
        glDisableVertexAttribArray(3)
        glDisableVertexAttribArray(2)
        glDisableVertexAttribArray(1)
        glDisableVertexAttribArray(0)

        glBindBuffer(GL_ARRAY_BUFFER, 0)
        glBindVertexArray(0)
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
