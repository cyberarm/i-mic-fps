# frozen_string_literal: true
IMICFPS_SERVER_MODE = true
require_relative "i-mic-fps"

director = IMICFPS::Networking::Director.new(mode: :server, hostname: "0.0.0.0", port: 56789, interface: IMICFPS::Networking::MemoryServer)
director.define_singleton_method(:tick) do |dt|
  puts "Ticked: #{dt}"
end

director.run.join