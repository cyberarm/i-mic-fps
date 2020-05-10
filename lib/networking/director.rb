class IMICFPS
  module Networking
    class Director
      attr_reader :address, :port, :tick_rate, :storage, :map
      def initialize(address: DEFAULT_SERVER_HOST, port: DEFAULT_SERVER_PORT, tick_rate: 2)
        @address = address
        @port = port
        @tick_rate = (1000.0 / tick_rate) / 1000.0

        @server = Server.new(address: @address, port: @port, max_peers: DEFAULT_PEER_LIMIT)
        @server.bind

        @last_tick_time = Networking.milliseconds
        @directing = true
        @storage = {}
        @map = nil
      end

      def load_map(map_parser:)
        # TODO: send map_change to clients
        @map = Map.new(map_parser: map_parser)
      end

      def run
        Thread.start do |thread|
          while(@directing)
            dt = milliseconds - @last_tick_time

            tick(dt)

            @last_tick_time = milliseconds
            sleep(@tick_rate)
          end
        end
      end

      def tick(delta_time)
        if @map
          Publisher.instance.publish(:tick, delta_time * 1000.0)

          @map.update
          @server.update
        end
      end

      def shutdown
        @directing = false
        @server.close
      end
    end
  end
end