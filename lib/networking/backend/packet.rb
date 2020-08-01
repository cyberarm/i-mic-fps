module CyberarmEngine
  module Networking
    class Packet
      attr_reader :protocol_version, :type, :peer_id, :message

      def self.type
        raise NotImplementedError, "#{self.class}.type must be defined!"
      end

      def self.decode(packet)
        raise NotImplementedError, "#{self.class}.decode must be defined!"
      end

      def encode
        raise NotImplementedError, "#{self.class}#encode must be defined!"
      end
    end
  end
end