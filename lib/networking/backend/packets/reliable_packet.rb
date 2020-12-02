# frozen_string_literal: true

module CyberarmEngine
  module Networking
    class ReliablePacket
      attr_reader :message, :type, :sequence_number

      HEADER_PACKER = "Cn"
      HEADER_LENGTH = 1 + 2 # bytes

      def self.decode(raw_message)
        header = raw_message.unpack(HEADER_PACKER)
        message = raw_message[HEADER_LENGTH..raw_message.length - 1]

        ReliablePacket.new(type: header[0], sequence_number: header[1], message: message)
      end

      def initialize(sequence_number:, message:, type: Protocol::PACKET_RELIABLE)
        @type = type
        @sequence_number = sequence_number
        @message = message
      end

      def encode
        header = [
          @type,
          @sequence_number
        ].pack(HEADER_PACKER)

        "#{header}#{@message}"
      end
    end
  end
end
