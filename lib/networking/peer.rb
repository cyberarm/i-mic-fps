class IMICFPS
  module Networking
    class Peer
      attr_reader :packet_read_queue, :packet_write_queue
      attr_accessor :packets_sent, :packets_received, :data_sent, :data_received, :last_read_time, :last_write_time
      def initialize(peer_id:, address:, port:)
        @address, @port = address, port
        @peer_id = peer_id

        @packet_write_queue = []
        @packet_read_queue = []

        @last_read_time = Networking.milliseconds
        @last_write_time = Networking.milliseconds

        @packets_sent = 0
        @packets_received = 0
        @data_sent = 0
        @data_received = 0
      end
    end
  end
end