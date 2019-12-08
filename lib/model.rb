class IMICFPS
  class Model
    include CommonMethods

    attr_accessor :objects, :materials, :vertices, :uvs, :texures, :normals, :faces, :colors, :bones
    attr_accessor :scale, :entity, :material_file, :current_material, :current_object, :vertex_count, :smoothing
    attr_reader :position, :bounding_box, :textured_material, :file_path

    attr_reader :positions_buffer_id, :colors_buffer_id, :normals_buffer_id, :uvs_buffer_id, :textures_buffer_id
    attr_reader :vertex_array_id
    attr_reader :aabb_tree

    def initialize(file_path:, entity: nil, parser:)
      @entity = entity
      update if @entity
      @file_path = file_path
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
      @bones    = []
      @smoothing= 0

      @bounding_box = BoundingBox.new
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)

      parse(parser)

      puts "#{@file_path.split('/').last} took #{((Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)-start_time)/1000.0).round(2)} seconds to parse" if $debug.get(:stats)

      if Shader.available?("default")
        allocate_gl_objects
        populate_vertex_buffer
        configure_vao
      end

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

    def parse(parser)
      parser.new(self).parse
    end

    def calculate_bounding_box(vertices, bounding_box)
      unless bounding_box.min.x.is_a?(Float)
        vertex = vertices.last
        bounding_box.min.x = vertex.x
        bounding_box.min.y = vertex.y
        bounding_box.min.z = vertex.z

        bounding_box.max.x = vertex.x
        bounding_box.max.y = vertex.y
        bounding_box.max.z = vertex.z
      end

      vertices.each do |vertex|
        bounding_box.min.x = vertex.x if vertex.x <= bounding_box.min.x
        bounding_box.min.y = vertex.y if vertex.y <= bounding_box.min.y
        bounding_box.min.z = vertex.z if vertex.z <= bounding_box.min.z

        bounding_box.max.x = vertex.x if vertex.x >= bounding_box.max.x
        bounding_box.max.y = vertex.y if vertex.y >= bounding_box.max.y
        bounding_box.max.z = vertex.z if vertex.z >= bounding_box.max.z
      end
    end

    def allocate_gl_objects
      # Allocate arrays for future use
      @vertex_array_id = nil
      buffer = " " * 4
      glGenVertexArrays(1, buffer)
      @vertex_array_id = buffer.unpack('L2').first

      # Allocate buffers for future use
      @positions_buffer_id = nil
      buffer = " " * 4
      glGenBuffers(1, buffer)
      @positions_buffer_id = buffer.unpack('L2').first

      @colors_buffer_id = nil
      buffer = " " * 4
      glGenBuffers(1, buffer)
      @colors_buffer_id = buffer.unpack('L2').first

      @normals_buffer_id = nil
      buffer = " " * 4
      glGenBuffers(1, buffer)
      @normals_buffer_id = buffer.unpack('L2').first

      @uvs_buffer_id = nil
      buffer = " " * 4
      glGenBuffers(1, buffer)
      @uvs_buffer_id = buffer.unpack('L2').first

      @textures_buffer_id = nil
      buffer = " " * 4
      glGenBuffers(1, buffer)
      @textures_buffer_id = buffer.unpack('L2').first
    end

    def populate_vertex_buffer
      pos     = []
      colors  = []
      norms   = []
      uvs     = []
      tex_ids = []

      @faces.each do |face|
        pos     << face.vertices.map { |vert| [vert.x, vert.y, vert.z] }
        colors  << face.colors.map   { |vert| [vert.x, vert.y, vert.z] }
        norms   << face.normals.map  { |vert| [vert.x, vert.y, vert.z, vert.weight] }

        if has_texture?
          uvs     << face.uvs.map    { |vert| [vert.x, vert.y, vert.z] }
          tex_ids << face.material.texture_id ? face.material.texture_id.to_f : -1.0
        end
      end

      glBindBuffer(GL_ARRAY_BUFFER, @positions_buffer_id)
      glBufferData(GL_ARRAY_BUFFER, pos.flatten.size * Fiddle::SIZEOF_FLOAT, pos.flatten.pack("f*"), GL_STATIC_DRAW)

      glBindBuffer(GL_ARRAY_BUFFER, @colors_buffer_id)
      glBufferData(GL_ARRAY_BUFFER, colors.flatten.size * Fiddle::SIZEOF_FLOAT, colors.flatten.pack("f*"), GL_STATIC_DRAW)

      glBindBuffer(GL_ARRAY_BUFFER, @normals_buffer_id)
      glBufferData(GL_ARRAY_BUFFER, norms.flatten.size * Fiddle::SIZEOF_FLOAT, norms.flatten.pack("f*"), GL_STATIC_DRAW)

      if has_texture?
        glBindBuffer(GL_ARRAY_BUFFER, @uvs_buffer_id)
        glBufferData(GL_ARRAY_BUFFER, uvs.flatten.size * Fiddle::SIZEOF_FLOAT, uvs.flatten.pack("f*"), GL_STATIC_DRAW)

        glBindBuffer(GL_ARRAY_BUFFER, @textures_buffer_id)
        glBufferData(GL_ARRAY_BUFFER, tex_ids.flatten.size * Fiddle::SIZEOF_FLOAT, tex_ids.flatten.pack("f*"), GL_STATIC_DRAW)
      end

      glBindBuffer(GL_ARRAY_BUFFER, 0)
    end

    def configure_vao
      glBindVertexArray(@vertex_array_id)

      program = Shader.get("default").program

      # index, size, type, normalized, stride, pointer
      # vertices (positions)
      glBindBuffer(GL_ARRAY_BUFFER, @positions_buffer_id)
      glVertexAttribPointer(glGetAttribLocation(program, "inPosition"), 3, GL_FLOAT, GL_FALSE, 0, nil)
      handleGlError
      # colors
      glBindBuffer(GL_ARRAY_BUFFER, @colors_buffer_id)
      glVertexAttribPointer(glGetAttribLocation(program, "inColor"), 3, GL_FLOAT, GL_FALSE, 0, nil)
      handleGlError
      # normals
      glBindBuffer(GL_ARRAY_BUFFER, @normals_buffer_id)
      glVertexAttribPointer(glGetAttribLocation(program, "inNormal"), 4, GL_FLOAT, GL_FALSE, 0, nil)
      handleGlError

      if has_texture?
        # uvs
        glBindBuffer(GL_ARRAY_BUFFER, @uvs_buffer_id)
        glVertexAttribPointer(glGetAttribLocation(program, "inUV"), 3, GL_FLOAT, GL_FALSE, 0, nil)
        handleGlError
        # texture ids
        glBindBuffer(GL_ARRAY_BUFFER, @textures_buffer_id)
        glVertexAttribPointer(glGetAttribLocation(program, "inTextureID"), 1, GL_FLOAT, GL_FALSE, 0, nil)
        handleGlError
      end

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
        box.min *= 1.5
        box.max *= 1.5
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
