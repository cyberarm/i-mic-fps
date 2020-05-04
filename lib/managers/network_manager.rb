class IMICFPS
  class NetworkManager
    MULTICAST_ADDRESS = "224.0.0.1"
    MULTICAST_PORT = 30_000

    REMOTE_GAMEHUB = "i-mic.rubyclan.org"
    REMOTE_GAMEHUB_PORT = 98765

    DEFAULT_SERVER_HOST = "0.0.0.0"
    DEFAULT_SERVER_PORT = 56789
    DEFAULT_SERVER_QUERY_PORT = 28900
    def initialize
    end

    # https://github.com/jpignata/blog/blob/master/articles/multicast-in-ruby.md
    def broadcast_lan_lobby
      socket = UDPSocket.open
      socket.setsockopt(:IPPROTO_IP, :IP_MULTICAST_TTL, 1)
      socket.send("IMICFPS_LAN_LOBBY", 0, MULTICAST_ADDRESS, MULTICAST_PORT)
      socket.close
    end

    def handle_lan_multicast
    end
  end
end