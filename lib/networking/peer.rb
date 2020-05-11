class IMICFPS
  module Networking
    class Peer
      attr_reader :id, :address, :port, :packet_read_queue, :packet_write_queue
      attr_accessor :total_packets_sent, :total_packets_received, :total_data_sent, :total_data_received, :last_read_time, :last_write_time
      def initialize(id:, address:, port:)
        @id = id
        @address, @port = address, port

        @packet_write_queue = []
        @packet_read_queue = []

        @last_read_time = Networking.milliseconds
        @last_write_time = Networking.milliseconds

        @total_packets_sent = 0
        @total_packets_received = 0
        @total_data_sent = 0
        @total_data_received = 0
      end
    end
  end
end