class IMICFPS
  class Commands
    class HelpCommand < Command
      def initialize
      end

      def group
        :global
      end

      def command
        :help
      end

      def handle(arguments, console)
        console.stdin(usage)
      end

      def usage
        "HELP\ncommand [arguments]\ncommand subcommand [argument]"
      end
    end
  end
end