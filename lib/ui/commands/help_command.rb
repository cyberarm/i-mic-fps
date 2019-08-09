class IMICFPS
  class Commands
    class HelpCommand < Command
      def group
        :global
      end

      def command
        :help
      end

      def handle(arguments, console)
        console.stdin(usage(arguments.first))
      end

      def usage(command = nil)
        if command
          if cmd = Command.find(command)
            cmd.usage
          else
            "#{Style.error(command)} is not a command"
          end
        else
          "Available commands:\n#{Command.list_commands.map { |cmd| "#{Style.highlight(cmd.command)}" }.join(', ')}"
        end
      end
    end
  end
end