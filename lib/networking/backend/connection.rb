module CyberarmEngine
  module Networking
    class Connection
      def initialize(hostname:, port:, channels: 3)
        @hostname = hostname
        @port = port

        @channels = Array(0..channels).map { |id| Channel.new(id: id, mode: :default) }

        @peer = Peer.new(id: 0, hostname: "", port: "")

        @last_read_time = Networking.milliseconds
        @last_write_time = Networking.milliseconds

        @total_packets_sent = 0
        @total_packets_received = 0
        @total_data_sent = 0
        @total_data_received = 0
      end

      # Callbacks #
      def connected
      end

      def disconnected(reason:)
      end

      def reconnected
      end

      def packet_received(message:, channel:)
      end

      # Functions #
      def send_packet(message:, reliable: false, channel: 0)
      end

      def connect(timeout: Protocol::TIMEOUT_PERIOD)
        @socket = UDPSocket.new

        write(PacketHandler.create_control_packet(peer: @peer, control_type: Protocol::CONTROL_CONNECT))
      end

      def disconnect(timeout: Protocol::TIMEOUT_PERIOD)
      end

      def update
        while read
        end

        @peer.write_queue.reverse.each do |packet|
          write(packet)
          @peer.write_queue.delete(packet)
        end

        if Networking.milliseconds - @last_write_time > Protocol::HEARTBEAT_INTERVAL
          @peer.write_queue << PacketHandler.create_control_packet(peer: @peer, control_type: Protocol::CONTROL_HEARTBEAT)
        end
      end

      private

      def read
        data, addr = @socket.recvfrom_nonblock(Protocol::MAX_PACKET_SIZE)
        pkt = PacketHandler.handle(host: self, raw: data, peer: @peer)
        packet_received(message: pkt.message, channel: -1) if pkt.is_a?(RawPacket)

        @total_packets_received += 1
        @total_data_received += data.length
        @last_read_time = Networking.milliseconds

        return true
      rescue IO::WaitReadable
        return false
      end

      def write(packet)
        raw = packet.encode
        @socket.send(raw, 0, @hostname, @port)

        @total_packets_sent += 1
        @total_data_sent += raw.length
        @last_write_time = Networking.milliseconds
      end
    end
  end
end
