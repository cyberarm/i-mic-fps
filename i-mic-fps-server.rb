require "async/websocket"

require_relative "lib/networking/director"
require_relative "lib/networking/packet_handler"
require_relative "lib/networking/server"
require_relative "lib/networking/client"

require_relative "lib/networking/backends/memory_server"
require_relative "lib/networking/backends/memory_connection"

director = IMICFPS::Networking::Director.new(mode: :server, hostname: "0.0.0.0", port: 56789, interface: IMICFPS::Networking::MemoryServer)
director.define_singleton_method(:tick) do |dt|
  puts "Ticked: #{dt}"
end

director.run.join