class IMICFPS
  module Networking
    module Protocol
      MAX_CLIENTS = 32
      MAX_PACKET_SIZE = 1024
      PROTOCOL_VERSION = 0 # int
      HEARTBEAT_INTERVAL = 250 # ms
      TIMEOUT_PERIOD = 30_000 # ms

      packet_types = %w{
        # protocol packets
        reliable
        multipart
        acknowledgement
        control
        data

        # protocol control packets
        connect
        disconnect
        authenticate
        heartbeat

        # game data packets
        client_connected
        client_disconnected
        entity_move
        play_sound_effect
        create_particle
      }

      # emulate c-like enum
      packet_types.each_with_index do |type, i|
        next if type.start_with?("#")
        self.const_set(:"#{type.upcase}", i)
      end
    end
  end
end