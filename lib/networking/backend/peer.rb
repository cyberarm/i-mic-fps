class Peer
  attr_reader :id, :hostname, :port, :data
  def initialize(id:, hostname:, port:)
    @id = id
    @hostname = hostname
    @port = port

    @data = {}
  end
end