module CyberarmEngine
  module Networking
    class Packet
      attr_reader :protocol_version, :peer_id, :channel, :message

      def self.decode(raw)
        header = raw.unpack(CyberarmEngine::Networking::Protocol::PACKET_BASE_HEADER)

        Packet.new(protocol_version: header[0], peer_id: header[1], channel: header[2], message: raw[Protocol::PACKET_BASE_HEADER_LENGTH...raw.length])
      end

      def initialize(protocol_version:, peer_id:, channel:, message:)
        @protocol_version = protocol_version
        @peer_id          = peer_id
        @channel          = channel
        @message          = message
      end

      def encode
        header = [
          @protocol_version,
          @peer_id,
          @channel
        ].pack(CyberarmEngine::Networking::Protocol::PACKET_BASE_HEADER)

        "#{header}#{@message}"
      end
    end
  end
end
