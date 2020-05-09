class IMICFPS
  module Networking
    class Client
      attr_reader :packets_sent, :packets_received,
                  :data_sent, :data_received
      def initialize(socket:)
        @socket = socket
        @write_queue = []
        @read_queue = []

        @packets_sent = 0
        @packets_received = 0
        @data_sent = 0
        @data_received = 0
      end

      def read
        data = @socket.recvfrom_nonblock(Protocol::MAX_PACKET_SIZE)
        @read_queue << Packet.decode(data)

        @packets_received += 1
        @data_received += data.length
        rescue IO::WaitReadable
      end

      def write
        @write_queue.each do |packet|
          raw = Packet.encode
          @socket.send(raw, 0)
          @write_queue.delete(packet)

          @packets_sent += 1
          @data_sent += raw.length
        end
      end

      def puts(packet)
        @write_queue << packet
      end

      def gets
        @read_queue.shift
      end

      def close
        @socket.close if @socket
      end
    end
  end
end