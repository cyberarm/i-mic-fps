class Server
  attr_reader :hostname, :port, :max_clients
  def initialize(hostname: "0.0.0.0", port: 56789, max_clients: 32, channels: 1)
    @hostname = hostname
    @port = port
    @max_clients = max_clients

    @socket = UDPSocket.new
    @socket.bind(@hostname, @port)

    @channels = Array(0..channels).map { |id| Channel.new(id: id, server: self) }
    @peers = []
  end

  # Helpers #
  def connected_clients
    @peers.size
  end

  def clients
    @peers
  end

  # Callbacks #

  # Called when client connects
  def client_connected(peer)
  end

  # Called when client times out or explicitly disconnects
  def client_disconnected(peer, reason)
  end

  ### REMOVE? ###
  # Called when client was not sending heartbeats or regular packets for a
  # period of time, but was not logically disconnected and removed, and started
  # send packets again.
  #
  # TLDR: Client was temporarily unreachable but did not timeout.
  def client_reconnected(peer)
  end

  # Called when a (logical) packet is received from client
  def packet_received(peer, message, channel = 0)
  end

  # Functions #
  # Send packet to specified peer
  def send_packet(peer, message, reliable, channel = 0)
  end

  # Send packet to all connected peer
  def broadcast_packet(message, reliable, channel = 0)
  end

  # Disconnect peer
  def disconnect_client(peer, reason = "")
  end
end