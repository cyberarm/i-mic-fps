class IMICFPS
  class Commands
    class ConnectCommand < Command
      def group
        :global
      end

      def command
        :connect
      end

      def handle(arguments, console)
      end

      def usage
        "Connect to a server.\n#{Style.highlight("connect")} #{Style.notice("[example.com:56789]")}"
      end
    end
  end
end