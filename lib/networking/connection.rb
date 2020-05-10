class IMICFPS
  module Networking
    class Connection
      attr_reader :address, :port
      attr_accessor :total_packets_sent, :total_packets_received, :total_data_sent, :total_data_received, :last_read_time, :last_write_time
      def initialize(address:, port:)
        @address = address
        @port = port


        @read_buffer = ReadBuffer.new
        @write_queue = []

        @last_read_time = Networking.milliseconds
        @last_write_time = Networking.milliseconds

        @total_packets_sent = 0
        @total_packets_received = 0
        @total_data_sent = 0
        @total_data_received = 0

        @socket = nil
      end

      def connect
        @socket = UDPSocket.new
        @socket.connect(@address, @port)

        send_packet(
          Packet.new(
            peer_id: 0,
            sequence: 0,
            type: Protocol::CONNECT,
            payload: "Hello World!"
          )
        )
      end

      def send_packet( packet )
      end

      def update
        while(read)
        end

        write

        @read_buffer.reconstruct_packets.each do |packet|
        end
      end

      def close
        @socket.close if @socket
      end

      private
      def read
        data, addr = @socket.recvfrom_nonblock(Protocol::MAX_PACKET_SIZE)
        @read_buffer.add(data, addr )

        @total_packets_received += 1
        @total_data_received += data.length
        @last_read_time = Networking.milliseconds
        return true
      rescue IO::WaitReadable
        return false
      end

      def write
        while(packet = @write_queue.shift)
          @socket.send( packet.encode, 0, @address, @port )
        end
      end
    end
  end
end