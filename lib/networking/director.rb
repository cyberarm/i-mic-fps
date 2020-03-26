class IMICFPS
  module Networking
    class Director
      attr_reader :mode, :hostname, :port, :tick_rate, :storage
      def initialize(mode:, hostname:, port:, interface:, state: nil, tick_rate: 2)
        @mode = mode
        @hostname = hostname
        @port = port
        @state = state
        @tick_rate = (1000.0 / tick_rate) / 1000.0

        case @mode
        when :server
          @server = interface.new(hostname: @hostname, port: @port)
        when :connection
          @connection = interface.new(hostname: @hostname, port: @port)
        when :memory
          @server = interface[:server].new(hostname: @hostname, port: @port)
          @connection = interface[:connection].new(hostname: @hostname, port: @port)
        else
          raise ArgumentError, "Expected mode to be :server, :connection, or :memory, not #{mode.inspect}"
        end

        @last_tick_time = milliseconds
        @directing = true
        @storage = {}
      end

      def run
        Thread.start do |thread|
          while(@directing)
            dt = milliseconds - @last_tick_time

            tick(dt)

            @server.update if @server
            @connection.update if @connection

            @last_tick_time = milliseconds
            sleep(@tick_rate)
          end
        end
      end

      def tick(dt)
      end

      def shutdown
        @directing = false

        @clients.each(&:close)
        @server.update if @server
        @connection.update if @connection
      end

      def milliseconds
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    end
  end
end