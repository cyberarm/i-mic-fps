# frozen_string_literal: true

class IMICFPS
  class Commands
    class RendererInfoCommand < CyberarmEngine::Console::Command
      def group
        :global
      end

      def command
        :renderer_info
      end

      def handle(_arguments, console)
        console.stdin("OpenGL Vendor:                  #{Console::Style.notice(glGetString(GL_VENDOR))}")
        console.stdin("OpenGL Renderer:                #{Console::Style.notice(glGetString(GL_RENDERER))}")
        console.stdin("OpenGL Version:                 #{Console::Style.notice(glGetString(GL_VERSION))}")
        console.stdin("OpenGL Shader Language Version: #{Console::Style.notice(glGetString(GL_SHADING_LANGUAGE_VERSION))}")
      end

      def usage
        "#{Console::Style.highlight('renderer_info')} #{Console::Style.notice('Returns OpenGL renderer information')}"
      end
    end
  end
end
