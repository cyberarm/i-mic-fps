def require_all(directory)
  files = Dir["#{directory}/**/*.rb"].sort!

  begin
    failed = []
    first_name_error = nil

    files.each do |file|
      begin
        require_relative file
      rescue NameError => name_error
        failed << file
        first_name_error ||= name_error
      end
    end

    if failed.size == files.size
      raise first_name_error
    else
      files = failed
    end
  end until(failed.empty?)
end

require "socket"
require_relative "lib/networking"
require_all "lib/networking/backend"

Thread.abort_on_exception = true

server = CyberarmEngine::Networking::Server.new
def server.client_connected(peer:)
  puts "Client connected as peer: #{peer.id}"
end

def server.packet_received(peer:, message:, channel:)
  pp "Server received: #{message} [on channel: #{channel} from peer: #{peer&.id}]"
  broadcast_packet(message: "Broadcasting...")
end

Thread.new do
  server.bind

  loop do
    server.update
    sleep (1000.0 / 60.0) / 10.0
  end
end

connection = CyberarmEngine::Networking::Connection.new(hostname: "localhost", port: CyberarmEngine::Networking::DEFAULT_SERVER_PORT, channels: 3)
def connection.connected
  puts "Connection: Connected!"
  send_packet(message: "I be connected!")
end

def connection.disconnected(reason:)
  puts "Connection: disconnected: #{reason}"
end

def connection.packet_received(message:, channel:)
  pp "Connection received: #{message} [on channel: #{channel} from peer: SERVER]"
  send_packet(message: "ECHO: #{message}")
end
connection.connect(timeout: 1_000)

loop do
  connection.update
  sleep (1000.0 / 60.0) / 10.0
end

sleep
