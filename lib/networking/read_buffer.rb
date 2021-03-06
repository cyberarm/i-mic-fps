# frozen_string_literal: true

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
          buffer = hash[:buffer]
          addr = hash[:addr_info]
          packet = Packet.from_stream(buffer)

          if true # packet.valid?
            pairs << [packet, addr]
            @buffer.delete(hash)
          else
            puts "Invalid packet: #{packet}"
            @buffer.delete(buffer)
          end
        end

        pairs
      end
    end
  end
end
