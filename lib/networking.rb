# frozen_string_literal: true
module CyberarmEngine
  module Networking
    MULTICAST_ADDRESS = "224.0.0.1"
    MULTICAST_PORT = 30_000

    REMOTE_GAMEHUB = "i-mic.cyberarm.dev"
    REMOTE_GAMEHUB_PORT = 98765

    DEFAULT_SERVER_HOSTNAME = "0.0.0.0"
    DEFAULT_SERVER_PORT = 56789
    DEFAULT_SERVER_QUERY_PORT = 28900

    RESERVED_PEER_ID = 0
    DEFAULT_PEER_LIMIT = 32
    HARD_PEER_LIMIT = 254

    def self.milliseconds
      Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond)
    end

    # https://github.com/jpignata/blog/blob/master/articles/multicast-in-ruby.md
    def self.broadcast_lan_lobby
      socket = UDPSocket.open
      socket.setsockopt(:IPPROTO_IP, :IP_MULTICAST_TTL, 1)
      socket.send("IMICFPS_LAN_LOBBY", 0, MULTICAST_ADDRESS, MULTICAST_PORT)
      socket.close
    end

    def self.handle_lan_multicast
    end
  end
end