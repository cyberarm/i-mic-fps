class IMICFPS
  module Networking
    class ReadBuffer
      def initialize
        @buffer = []
      end

      def add(buffer, addr_info)
        @buffer << { buffer: buffer, addr_info: addr_info }
      end

      def reconstruct_packets
        pairs = []

        @buffer.each do |hash|
          buffer, addr = hash[:buffer], hash[:addr_info]
          packet = Packet.from_stream(buffer)

          if true#packet.valid?
            pairs << [packet, addr]
            @buffer.delete(buffer)
          else
            puts "Invalid packet: #{packet}"
            @buffer.delete(buffer)
          end
        end

        return pairs
      end
    end
  end
end