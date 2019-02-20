class IMICFPS
  # Ref: https://github.com/vaiorabbit/ruby-opengl/blob/master/sample/OrangeBook/brick.rb
  class Shader
    include OpenGL

    def initialize(name:, vertex_file:, fragment_file:)
      @name = name
      @vertex_file   = vertex_file
      @fragment_file = fragment_file
      @compiled = false

      @error_buffer_size = 1024
      @variable_missing = {}

      create_shaders
      compile_shaders

      # Only add shader to ShaderManager if it successfully compiles
      if @compiled
        ShaderManager.add_shader(@name, self)
      else
        puts "FAILED to compile shader: #{@name}", ""
      end
    end

    def shader_files_exist?
      File.exists?(@vertex_file) && File.exists?(@fragment_file)
    end

    def create_shaders
      return unless shader_files_exist?

      @vertex   = glCreateShader(GL_VERTEX_SHADER)
      @fragment = glCreateShader(GL_FRAGMENT_SHADER)

      source = [File.read(@vertex_file)].pack('p')
      size   = [File.size(@vertex_file)].pack('I')
      glShaderSource(@vertex, 1, source, size)

      source = [File.read(@fragment_file)].pack('p')
      size   = [File.size(@fragment_file)].pack('I')
      glShaderSource(@fragment, 1, source, size)
    end

    def compile_shaders
      return unless shader_files_exist?

      glCompileShader(@vertex)
      buffer = '    '
      glGetShaderiv(@vertex, GL_COMPILE_STATUS, buffer)
      compiled = buffer.unpack('L')[0]

      if compiled == 0
        log = ' ' * @error_buffer_size
        glGetShaderInfoLog(@vertex, @error_buffer_size, nil, log)
        puts "Shader Error: Program \"#{@name}\""
        puts "  Vector Shader InfoLog:", "  #{log.strip.split("\n").join("\n  ")}\n\n"
        puts "  Shader Compiled status: #{compiled}"
        puts "    NOTE: assignment of uniforms in shaders is illegal!"
        puts
        return
      end

      glCompileShader(@fragment)
      buffer = '    '
      glGetShaderiv(@fragment, GL_COMPILE_STATUS, buffer)
      compiled = buffer.unpack('L')[0]

      if compiled == 0
        log = ' ' * @error_buffer_size
        glGetShaderInfoLog(@fragment, @error_buffer_size, nil, log)
        puts "Shader Error: Program \"#{@name}\""
        puts "  Fragment Shader InfoLog:", "  #{log.strip.split("\n").join("\n  ")}\n\n"
        puts "  Shader Compiled status: #{compiled}"
        puts "    NOTE: assignment of uniforms in shader is illegal!"
        puts
        return
      end

      @program = glCreateProgram
      glAttachShader(@program, @vertex)
      glAttachShader(@program, @fragment)
      glLinkProgram(@program)

      buffer = '    '
      glGetProgramiv(@program, GL_LINK_STATUS, buffer)
      linked = buffer.unpack('L')[0]

      if linked == 0
        log = ' ' * @error_buffer_size
        glGetProgramInfoLog(@program, @error_buffer_size, nil, log)
        puts "Shader Error: Program \"#{@name}\""
        puts "  Program InfoLog:", "  #{log.strip.split("\n").join("\n  ")}\n\n"
      end

      @compiled = linked == 0 ? false : true
    end

    # Returns the location of a uniform variable
    def variable(variable)
      loc = glGetUniformLocation(@program, variable)
      if (loc == -1)
        puts "Shader Error: Program \"#{@name}\" has no such uniform named \"#{variable}\"", "  Is it used in the shader? GLSL may have optimized it out.", "  Is it miss spelled?" unless @variable_missing[variable]
        @variable_missing[variable] = true
      end
      return loc
    end

    def use(&block)
      return unless compiled?
      glUseProgram(@program)

      if block
        block.call(self)
        stop
      end
    end

    def stop
      glUseProgram(0)
    end

    def compiled?
      @compiled
    end
  end
end