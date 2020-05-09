class IMICFPS
  module Networking
    module Protocol
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
        snapshot
        player_joined
        player_left
        play_sound_effect
        create_particle
        create_entity
        remove_entity
      }

      # emulate c-like enum
      packet_types.each_with_index do |type, i|
        next if type.start_with?("#")
        self.const_set(:"#{type.upcase}", i)
      end
    end
  end
end