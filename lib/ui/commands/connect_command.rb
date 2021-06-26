# frozen_string_literal: true

class IMICFPS
  class Commands
    class ConnectCommand < CyberarmEngine::Console::Command
      def group
        :global
      end

      def command
        :connect
      end

      def handle(arguments, console)
      end

      def usage
        "Connect to a server.\n#{Console::Style.highlight('connect')} #{Style.notice('example.com[:56789]')}"
      end
    end
  end
end
