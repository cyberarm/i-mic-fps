module CyberarmEngine
  module Networking
    class ReliablePacket
      attr_reader :message, :type, :control_type

      HEADER_PACKER = "Cn"
      HEADER_LENGTH = 1 + 2 # bytes

      def self.decode(raw_message)
        header = raw_message.unpack(HEADER_PACKER)
        message = raw_message[HEADER_LENGTH..raw_message.length - 1]

        ReliablePacket.new(type: header[0], control_type: header[1], message: message)
      end

      def initialize(sequence_number:, message:, type: Protocol::PACKET_RELIABLE)
        @type = type
        @sequence_number = sequence_number
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
