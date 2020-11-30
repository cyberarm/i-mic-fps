module CyberarmEngine
  module Networking
    class RawPacket
      attr_reader :message, :type

      HEADER_PACKER = "C"
      HEADER_LENGTH = 1 # bytes

      def self.decode(raw_message)
        header = raw_message.unpack(HEADER_PACKER)
        message = raw_message[HEADER_LENGTH..raw_message.length - 1]

        RawPacket.new(type: header[0], message: message)
      end

      def initialize(message:, type: Protocol::PACKET_RAW)
        @type = type
        @message = message
      end

      def encode
        header = [
          @type
        ].pack(HEADER_PACKER)

        "#{header}#{@message}"
      end
    end
  end
end
