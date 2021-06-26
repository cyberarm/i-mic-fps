# frozen_string_literal: true

class IMICFPS
  class Commands
    class ReloadShaderCommand < CyberarmEngine::Console::Command
      def group
        :reload_shader
      end

      def command
        :reload_shader
      end

      def handle(arguments, console)
        if arguments.size > 2
          console.stdin("to many arguments for #{Console::Style.highlight(command.to_s)}, got #{Console::Style.error(arguments.size)} expected #{Console::Style.notice(1)}.")
          return
        end

        shader = nil
        stdout = $stdout
        $stdout = StringIO.new

        case arguments.size
        when 0
          console.stdin(usage)
          return
        when 1
          name = arguments.first
          Shader.delete(name)

          shader = Shader.new(
            name: name,
            includes_dir: "shaders/include",
            vertex: "shaders/vertex/#{name}.glsl",
            fragment: "shaders/fragment/#{name}.glsl"
          )
        when 2
          vertex = arguments.first
          fragment = arguments.last
          Shader.remove(vertex)

          shader = Shader.new(
            name: vertex,
            includes_dir: "shaders/include",
            vertex: "shaders/vertex/#{vertex}.glsl",
            fragment: "shaders/fragment/#{fragment}.glsl"
          )
        end

        string = $stdout.string

        if shader.compiled?
          console.stdin("#{Console::Style.notice('Successfully reloaded shader')}: #{shader.name}")
        else
          console.stdin(Console::Style.error("Failed to reload #{shader.name}").to_s)
          console.stdin(string)
        end
      ensure
        $stdout = stdout
        puts string if string
      end

      def usage
        "#{Console::Style.highlight(command)} #{Console::Style.notice('vertex_name [fragment_name]')}"
      end
    end
  end
end
