module CyberarmEngine
  module Networking
    class ControlPacket
      attr_reader :message, :type, :control_type

      HEADER_PACKER = "CC"
      HEADER_LENGTH = 1 + 1 # bytes

      def self.decode(raw_message)
        header = raw_message.unpack(HEADER_PACKER)
        message = raw_message[HEADER_LENGTH..raw_message.length - 1]

        ControlPacket.new(type: header[0], control_type: header[1], message: message)
      end

      def initialize(control_type:, message: nil, type: Protocol::PACKET_CONTROL)
        @type = type
        @control_type = control_type
        @message = message
      end

      def encode
        header = [
          @type,
          @control_type
        ].pack(HEADER_PACKER)

        "#{header}#{@message}"
      end
    end
  end
end
