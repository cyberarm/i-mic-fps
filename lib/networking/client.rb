class IMICFPS
  module Networking
    class Client
      attr_reader :uuid,
                  :packets_sent, :packets_received,
                  :data_sent, :data_received
      def initialize(socket:)
        @socket = socket
        @write_queue = []
        @read_queue = []

        @uuid = "not_defined"

        @packets_sent = 0
        @packets_received = 0
        @data_sent = 0
        @data_received = 0
      end

      def read
      end

      def write
      end

      def puts(packet)
        @write_queue << packet
      end

      def gets
        @socket.recvfrom_nonblock(Protocol::MAX_PACKET_SIZE)
      end

      def close
        @socket.close if @socket
      end
    end
  end
end