module CyberarmEngine
  module Networking
    module Protocol
      MAX_PACKET_SIZE = 1024
      PROTOCOL_VERSION = 0 # int
      HEARTBEAT_INTERVAL = 5_000 # ms
      TIMEOUT_PERIOD = 30_000 # ms

      packet_types = %w{
        # protocol packets
        reliable
        multipart
        control
        data

        # control packet types
        disconnect
        acknowledge
        heartbeat
        ping
      }

      # emulate c-like enum
      packet_types.each_with_index do |type, i|
        next if type.start_with?("#")
        self.const_set(:"#{type.upcase}", i)
      end
    end
  end
end