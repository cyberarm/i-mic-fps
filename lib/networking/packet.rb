class IMICFPS
  module Networking
    class Packet
      HEADER_PACKER = "CnCnCC"
      HEADER_SIZE = 8

      def self.from_stream(raw)
        header = raw[ 0..HEADER_SIZE ].unpack(HEADER_PACKER)
        payload = raw[HEADER_SIZE..raw.length - 1]

        new(peer_id: header.last, sequence: header[1], type: header[2], payload: payload)
      end

      # TODO: Handle splitting big packets into smaller ones
      def self.splinter(packet)
        packets = [packet]

        return packets
      end

      attr_reader :peer_id, :sequence_number, :type, :parity, :payload, :content_length
      def initialize(peer_id:, sequence:, type:, payload:)
        @peer_id = peer_id
        @sequence_number = sequence
        @type = type
        @parity = calculate_parity
        @payload = payload

        @content_length = payload.length
      end

      def header
        [
          Protocol::PROTOCOL_VERSION, # char
          @sequence_number,           # uint16
          @type,                      # char
          @content_length,            # uint16
          @parity,                    # char
          @peer_id,                   # char
        ].pack(HEADER_PACKER)
      end

      def calculate_parity
        return 0
      end

      def encode
        "#{header}#{@payload}"
      end

      def decode(payload)
        payload
      end
    end
  end
end