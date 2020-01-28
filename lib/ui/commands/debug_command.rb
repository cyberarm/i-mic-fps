class IMICFPS
  class Commands
    class DebugCommand < Command
      def group
        :global
      end

      def command
        :debug
      end

      def setup
        $debug = self

        set(:boundingboxes, false)
        set(:wireframe, false)
        set(:stats, false)
        set(:fps, false)
        set(:skydome, true)
        set(:use_shaders, true)
        set(:opengl_error_panic, false)

        subcommand(:boundingboxes, :boolean)
        subcommand(:wireframe, :boolean)
        subcommand(:stats, :boolean)
        subcommand(:skydome, :boolean)
        subcommand(:use_shaders, :boolean)
        subcommand(:opengl_error_panic, :boolean)
      end

      def handle(arguments, console)
        handle_subcommand(arguments, console)
      end

      def usage
        "debug\n    #{@subcommands.map { |sub| sub.usage }.join("\n    ")}"
      end
    end
  end
end
