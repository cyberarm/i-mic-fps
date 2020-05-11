class IMICFPS
  module Networking
    class Server
      attr_reader :address, :port, :max_peers, :peers
      attr_accessor :total_packets_sent, :total_packets_received, :total_data_sent, :total_data_received, :last_read_time, :last_write_time
      def initialize(address:, port:, max_peers:)
        @address = address
        @port = port
        @max_peers = max_peers

        @peers = Array.new(@max_peers + 1, nil)

        @read_buffer = ReadBuffer.new

        @last_read_time = Networking.milliseconds
        @last_write_time = Networking.milliseconds

        @total_packets_sent = 0
        @total_packets_received = 0
        @total_data_sent = 0
        @total_data_received = 0
      end

      # Peer ID 0 is reserved for unconnected peers to pass packet validation
      def create_peer(address:, port:)
        @peers.each_with_index do |peer, i|
          unless peer
            new_peer = Peer.new(id: i + 1, address: address, port: port)
            @peers[i + 1] = new_peer

            return new_peer
          end
        end

        return nil
      end

      def get_peer(peer_id)
        @peers[peer_id]
      end

      def remove_peer(peer_id)
        @peers[peer_id] = nil
      end

      def bind
        @socket = UDPSocket.new
        @socket.bind(@address, @port)
      end

      def send_packet( peer_id, packet )
        if peer = get_peer(peer_id)
          packets = Packet.splinter(packet)

          packets.each { |pkt| peer.packet_write_queue.push(pkt) }
        end
      end

      def broadcast_packet(packet)
        @peers.each do |peer|
          next unless peer

          send_packet(peer.id, packet)
        end
      end

      def update
        while(read)
        end

        @peers.each do |peer|
          next unless peer

          peer.packet_write_queue.each do |packet|
            write(peer, packet)
            peer.packet_write_queue.delete(packet)
          end
        end

        # "deliver" packets to peers, record stats to peers
        @read_buffer.reconstruct_packets.each do |packet, addr_info|
          peer = nil

          # initial connection
          if packet.peer_id == 0 && packet.type == Protocol::CONNECT
            peer = create_peer(address: addr_info[2], port: addr_info[1])
            send_packet(
              peer.id,
              Packet.new(
                peer_id: 0,
                sequence: 0,
                type: Protocol::VERIFY_CONNECT,
                payload: [peer.id].pack("C")
              )
            )
          else
            peer = get_peer(packet.peer_id)
          end
        end

        # broadcast_packet(Packet.new(peer_id: 0, sequence: 0, type: Protocol::HEARTBEAT, payload: [Networking.milliseconds].pack("G")))
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

      def write(peer, packet)
        raw = packet.encode
        @socket.send( raw, 0, peer.address, peer.port )

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