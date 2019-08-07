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
        subcommand(:boundingboxes, :boolean)
        subcommand(:wireframe, :boolean)
        subcommand(:fps, :boolean)
        subcommand(:stats, :boolean)
        subcommand(:motd, :string)
        subcommand(:mode, :integer)
        subcommand(:gravity, :decimal)
      end

      def handle(arguments, console)
        handle_subcommand(arguments, console)
      end

      def usage
        string = "debug\n    #{@subcommands.map { |sub| sub.usage }.join("\n    ")}"
      end
    end
  end
end