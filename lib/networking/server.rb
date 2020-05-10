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
            new_peer = Peer.new(peer_id: i + 1, address: address, port: port)
            @peers[i + 1] = new_peer

            return new_peer
          end
        end
      end

      def get_peer(peer_id)
        @peers[peer_id + 1]
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

          packets.each { |pkt| peer.write_queue.add(pkt) }
        end
      end

      def broadcast_packet(packet)
        @peers.each do |peer|
          send_packet(peer.peer_id, packet)
        end
      end

      def update
        while(read)
        end

        # "deliver" packets to peers, record stats to peers
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