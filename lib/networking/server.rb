# frozen_string_literal: true

class IMICFPS
  module Networking
    class Server < CyberarmEngine::Networking::Server
      def connected(peer:)
      end

      def disconnected(peer:, reason:)
      end

      def packet_received(peer:, message:, channel:)
      end
    end
  end
end
