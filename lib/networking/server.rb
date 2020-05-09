class IMICFPS
  module Networking
    class Server
      MAX_CLIENTS = 32

      attr_reader :hostname, :port, :max_clients, :clients
      def initialize(hostname:, port:, max_clients: MAX_CLIENTS)
        @hostname = hostname
        @port = port
        @max_clients = max_clients

        @clients = []
        @socket = nil
      end

      def bind
      end

      def broadcast(packet)
      end

      def update
      end

      def close
      end
    end
  end
end