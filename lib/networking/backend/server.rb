module CyberarmEngine
  module Networking
    class Server
      attr_reader :hostname, :port, :max_clients
      attr_accessor :total_packets_sent, :total_packets_received,
                    :total_data_sent, :total_data_received,
                    :last_read_time, :last_write_time

      def initialize(
        hostname: CyberarmEngine::Networking::DEFAULT_SERVER_HOSTNAME,
        port: CyberarmEngine::Networking::DEFAULT_SERVER_PORT,
        max_clients: CyberarmEngine::Networking::DEFAULT_PEER_LIMIT,
        channels: 3
      )
        @hostname = hostname
        @port = port
        @max_clients = max_clients + 2

        @channels = Array(0..channels).map { |id| Channel.new(id: id, mode: :default) }
        @peers = []

        @last_read_time = Networking.milliseconds
        @last_write_time = Networking.milliseconds

        @total_packets_sent = 0
        @total_packets_received = 0
        @total_data_sent = 0
        @total_data_received = 0
      end

      # Helpers #
      def connected_clients
        @peers.size
      end

      def clients
        @peers
      end

      # Callbacks #

      # Called when client connects
      def client_connected(peer:)
      end

      # Called when client times out or explicitly disconnects
      def client_disconnected(peer:, reason:)
      end

      ### REMOVE? ###
      # Called when client was not sending heartbeats or regular packets for a
      # period of time, but was not logically disconnected and removed, and started
      # send packets again.
      #
      # TLDR: Client was temporarily unreachable but did not timeout.
      def client_reconnected(peer:)
      end

      # Called when a (logical) packet is received from client
      def packet_received(peer:, message:, channel:)
      end

      # Functions #
      # Bind server
      def bind
        # TODO: Handle socket errors
        @socket = UDPSocket.new
        @socket.bind(@hostname, @port)
      end

      # Send packet to specified peer
      def send_packet(peer:, message:, reliable: false, channel: 0)
        if (peer = @peers[peer])
          packet = PacketHandler.create_raw_packet(message, reliable, channel)
          peer.write_queue << packet
        else
          # TODO: Handle no such peer error
        end
      end

      # Send packet to all connected peer
      def broadcast_packet(message:, reliable: false, channel: 0)
        @peers.each { |peer| send_packet(peer: peer.id, message: message, reliable: reliable, channel: channel) }
      end

      # Disconnect peer
      def disconnect_client(peer:, reason: "")
        if (peer = @peers[peer])
          packet = PacketHandler.create_disconnect_packet(peer.id, reason)
          peer.write_now!(packet)
          @peers.delete(peer)
        end
      end

      def update
        while(read)
        end

        # handle write queue
        # TODO: handle reliable packets differently
        @peers.each do |peer|
          if Networking.milliseconds - peer.last_read_time > Protocol::TIMEOUT_PERIOD
            message = "ERROR: connection timed out"

            write(
              peer: peer,
              packet: PacketHandler.create_control_packet(
                peer: peer,
                control_type: Protocol::CONTROL_DISCONNECT,
                message: message
              )
            )
            client_disconnected(peer: peer, reason: message)
            @peers.delete(peer)
            next
          end

          if Networking.milliseconds - peer.last_write_time > Protocol::HEARTBEAT_INTERVAL
            write(
              peer: peer,
              packet: PacketHandler.create_control_packet(
                peer: peer,
                control_type: Protocol::CONTROL_PING
              )
            )
          end

          while(packet = peer.write_queue.shift)
            write(peer: peer, packet: packet)
          end
        end
      end

      # !--- this following functions are meant for internal use only ---! #

      def available_peer_id
        peer_ids = @peers.map(&:id)
        ids = (2..@max_clients).to_a - peer_ids

        ids.size.positive? ? ids.first : nil
      end

      def read
        data, addr = @socket.recvfrom_nonblock(Protocol::MAX_PACKET_SIZE)
        peer = nil

        if (peer = @peers.find { |pr| pr.hostname == addr[2] && pr.port == addr[1] })
          pkt = PacketHandler.handle(host: self, raw: data, peer: peer)
          packet_received(peer: peer, message: pkt.message, channel: 0) if pkt.is_a?(RawPacket)
        else
          peer = Peer.new(id: 0, hostname: addr[2], port: addr[1])
          pkt = PacketHandler.handle(host: self, raw: data, peer: peer)

          if pkt && !pkt.is_a?(ControlPacket) && pkt.control_type != Protocol::CONTROL_CONNECT
            write(
              peer: peer,
              packet: PacketHandler.create_control_packet(
                peer: peer,
                control_type: Protocol::CONTROL_DISCONNECT,
                message: "ERROR: client not connected"
              )
            )
          end
        end

        @total_packets_received += 1
        @total_data_received += data.length
        @last_read_time = Networking.milliseconds

        peer.total_packets_received += 1
        peer.total_data_received += data.length
        peer.last_read_time = Networking.milliseconds

        true
      rescue IO::WaitReadable
        false
      end

      def write(peer:, packet:)
        raw = packet.encode
        @socket.send(raw, 0, peer.hostname, peer.port)

        @total_packets_sent += 1
        @total_data_sent += raw.length
        @last_write_time = Networking.milliseconds

        peer.total_packets_sent += 1
        peer.total_data_sent += raw.length
        peer.last_write_time = Networking.milliseconds
      end
    end
  end
end
