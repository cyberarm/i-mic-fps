# frozen_string_literal: true

class IMICFPS
  class Commands
    class RendererInfoCommand < Command
      def group
        :global
      end

      def command
        :renderer_info
      end

      def handle(_arguments, console)
        console.stdin("OpenGL Vendor:                  #{Style.notice(glGetString(GL_VENDOR))}")
        console.stdin("OpenGL Renderer:                #{Style.notice(glGetString(GL_RENDERER))}")
        console.stdin("OpenGL Version:                 #{Style.notice(glGetString(GL_VERSION))}")
        console.stdin("OpenGL Shader Language Version: #{Style.notice(glGetString(GL_SHADING_LANGUAGE_VERSION))}")
      end

      def usage
        "#{Style.highlight('renderer_info')} #{Style.notice('Returns OpenGL renderer information')}"
      end
    end
  end
end
