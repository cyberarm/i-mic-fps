# frozen_string_literal: true

module CyberarmEngine
  module Networking
    module Protocol
      MAX_PACKET_SIZE = 1024 # bytes
      PROTOCOL_VERSION = 0 # u32
      HEARTBEAT_INTERVAL = 5_000 # ms
      TIMEOUT_PERIOD = 30_000 # ms

      PACKET_BASE_HEADER = "NnC" # protocol version (u32), sender peer id (u16), channel (u8)
      PACKET_BASE_HEADER_LENGTH = 4 + 2 + 1 # bytes

      # protocol packets
      PACKET_RELIABLE  = 0
      PACKET_FRAGMENT  = 1
      PACKET_CONTROL   = 2
      PACKET_RAW       = 3

      # control packet types
      CONTROL_CONNECT      = 30
      CONTROL_SET_PEER_ID  = 31
      CONTROL_DISCONNECT   = 32
      CONTROL_ACKNOWLEDGE  = 33
      CONTROL_HEARTBEAT    = 34
      CONTROL_PING         = 35
      CONTROL_PONG         = 36
      CONTROL_SET_PEER_MTU = 37 # In future
    end
  end
end
