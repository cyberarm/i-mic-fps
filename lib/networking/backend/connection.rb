class Connection
  def initialize(hostname:, port:, max_clients:, channels: 1)
  end

  # Callbacks #
  def connected
  end

  def disconnected(reason)
  end

  def reconnected
  end

  def packet_received(message, channel)
  end

  # Functions #
  def send_packet(message, reliable, channel = 0)
  end

  def broadcast_packet(message, reliable, channel = 0)
  end

  def disconnect(reason = "")
  end
end