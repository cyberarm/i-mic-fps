# frozen_string_literal: true

class IMICFPS
  class Commands
    class DisconnectCommand < Command
      def group
        :global
      end

      def command
        :disconnect
      end

      def handle(arguments, console)
      end

      def usage
        "Disconnect from currently connected server, if any."
      end
    end
  end
end
