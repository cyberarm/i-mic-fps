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

        subcommand(:boundingboxes, :boolean)
        subcommand(:wireframe, :boolean)
        subcommand(:stats, :boolean)
        subcommand(:skydome, :boolean)
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