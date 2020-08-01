module CyberarmEngine
  module Networking
    class DataPacket < Packet
      HEADER_PACKER = "CCn"
      HEADER_LENGTH = 1 + 1 + 4 # bytes

      def self.type
        Protocol::DATA
      end

      def self.decode(raw_message)
        header = raw_message.unpack(HEADER_PACKER)
        message = raw_message[HEADER_LENGTH..raw_message.length - 1]

        DataPacket.new(protocol_version: header[0], type: header[1], message: message)
      end

      def initialize(protocol_version:, type:, peer_id:, message:)
        @protocol_version = protocol_version
        @type = type
        @peer_id = peer_id

        @message = message
      end

      def encode
        header = [
          Protocol::PROTOCOL_VERSION,
          @type,
          @peer_id,
        ].pack(HEADER_PACKER)

        "#{header}#{message}"
      end
    end
  end
end