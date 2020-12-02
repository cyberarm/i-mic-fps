# frozen_string_literal: true

module CyberarmEngine
  module Networking
    class Peer
      attr_reader :id, :hostname, :port, :data, :read_queue, :write_queue
      attr_accessor :total_packets_sent, :total_packets_received,
                    :total_data_sent, :total_data_received,
                    :last_read_time, :last_write_time,
                    :ping

      def initialize(id:, hostname:, port:)
        @id = id
        @hostname = hostname
        @port = port

        @data = {}
        @read_queue = []
        @write_queue = []

        @last_read_time = Networking.milliseconds
        @last_write_time = Networking.milliseconds

        @total_packets_sent = 0
        @total_packets_received = 0
        @total_data_sent = 0
        @total_data_received = 0

        @ping = 0

        @reliable_sequence_number = 65_500
      end

      def id=(n)
        raise "Peer id must be an integer" unless n.is_a?(Integer)

        @id = n
      end

      def next_reliable_sequence_number
        @reliable_sequence_number = (@reliable_sequence_number + 1) % 65_535
      end
    end
  end
end
