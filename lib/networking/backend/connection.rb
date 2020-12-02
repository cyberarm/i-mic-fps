module CyberarmEngine
  module Networking
    class Connection
      attr_reader :hostname, :port, :peer

      def initialize(hostname:, port:, channels: 3)
        @hostname = hostname
        @port = port

        @channels = Array(0..channels).map { |id| Channel.new(id: id, mode: :default) }

        @peer = Peer.new(id: 0, hostname: "", port: "")
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
        @peer.write_queue << PacketHandler.create_raw_packet(peer: @peer, message: message, reliable: reliable, channel: channel)
      end

      def connect(timeout: Protocol::TIMEOUT_PERIOD)
        @socket = UDPSocket.new

        write(packet: PacketHandler.create_control_packet(peer: @peer, control_type: Protocol::CONTROL_CONNECT))
      end

      def disconnect(timeout: Protocol::TIMEOUT_PERIOD)
      end

      def update
        while read
        end

        @peer.write_queue.reverse.each do |packet|
          write(packet: packet)
          @peer.write_queue.delete(packet)
        end

        if Networking.milliseconds - @peer.last_write_time > Protocol::HEARTBEAT_INTERVAL
          @peer.write_queue << PacketHandler.create_control_packet(peer: @peer, control_type: Protocol::CONTROL_HEARTBEAT)
        end
      end

      def read
        data, addr = @socket.recvfrom_nonblock(Protocol::MAX_PACKET_SIZE)
        pkt = PacketHandler.handle(host: self, raw: data, peer: @peer)
        packet_received(message: pkt.message, channel: -1) if pkt.is_a?(RawPacket)

        @peer.total_packets_received += 1
        @peer.total_data_received += data.length
        @peer.last_read_time = Networking.milliseconds

        return true
      rescue IO::WaitReadable
        return false
      end

      def write(packet:)
        raw = packet.encode
        @socket.send(raw, 0, @hostname, @port)

        @peer.total_packets_sent += 1
        @peer.total_data_sent += raw.length
        @peer.last_write_time = Networking.milliseconds
      end
    end
  end
end
