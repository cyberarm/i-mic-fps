class IMICFPS
  module Networking
    class Packet
      HEADER_PACKER = "CnCnC"
      HEADER_SIZE = 7

      def self.from_stream(raw)
        header = raw[ 0..HEADER_SIZE ].unpack(HEADER_PACKER)
        payload = raw[HEADER_SIZE + 1..raw.length - 1]

        new(header[1], [2], payload)
      end

      def initialize(sequence:, type:, payload:)
        @sequence_number = sequence
        @packet_type = type
        @content_length = payload.length
        @parity = calculate_parity
        @payload = payload
      end

      def header
        [
          Protocol::PROTOCOL_VERSION, # char
          @sequence_number,           # uint16
          @packet_type,               # char
          @content_length,            # uint16
          @parity,                    # char
        ].unpack(HEADER_PACKER)
      end

      def calculate_parity
        return 0
      end

      def encode
        "#{header}#{@payload}"
      end

      def decode(payload)
      end
    end
  end
end