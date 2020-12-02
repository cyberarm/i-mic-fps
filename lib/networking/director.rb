# frozen_string_literal: true
class IMICFPS
  module Networking
    class Director
      attr_reader :tick_rate, :storage, :map, :server, :connection

      def initialize(tick_rate: 15)
        @tick_rate = (1000.0 / tick_rate) / 1000.0

        @last_tick_time = CyberarmEngine::Networking.milliseconds
        @directing = true
        @storage = {}
        @map = nil
      end

      def host_server(hostname: CyberarmEngine::Networking::DEFAULT_SERVER_HOSTNAME, port: CyberarmEngine::Networking::DEFAULT_SERVER_PORT, max_peers: CyberarmEngine::Networking::DEFAULT_PEER_LIMIT)
        @server = Server.new(hostname: hostname, port: port, max_peers: max_peers)
        @server.bind
      end

      def connect(hostname:, port: CyberarmEngine::Networking::DEFAULT_SERVER_PORT)
        @connection = Connection.new(hostname: hostname, port: port)
        @connection.connect
      end

      def load_map(map_parser:)
        # TODO: send map_change to clients
        @map = Map.new(map_parser: map_parser)
        @map.setup
      end

      def run
        Thread.start do
          while @directing
            dt = milliseconds - @last_tick_time

            tick(dt)

            @last_tick_time = milliseconds
            sleep(@tick_rate)
          end
        end
      end

      def tick(delta_time)
        return unless @map

        Publisher.instance.publish(:tick, delta_time * 1000.0)

        @map.update
        @server&.update
        @connection&.update
      end

      def shutdown
        @directing = false
        @server&.close
        @connection&.close
      end
    end
  end
end
