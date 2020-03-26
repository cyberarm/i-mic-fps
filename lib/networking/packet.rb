class IMICFPS
  module Networking
    class Packet
      def initialize(type:, payload:)
      end

      def self.encode(packet)
        "#{packet.type}|#{packet.payload}"
      end

      def self.decode(string)
        split = string.split("|")

        Packet.new(split.first, split.last)
      end
    end
  end
end