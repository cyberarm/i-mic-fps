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
        packets = []

        @buffer.each do |buffer, addr_info|
          packet = Packet.from_stream(buffer)

          if packet.valid?
            @buffer.delete(buffer)
          else
            puts "Invalid packet: #{packet}"
            @buffer.delete(buffer)
          end
        end

        return packets
      end
    end
  end
end