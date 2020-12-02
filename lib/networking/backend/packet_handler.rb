# frozen_string_literal: true

module CyberarmEngine
  module Networking
    module PacketHandler
      def self.type_to_name(type:)
        Protocol.constants.select { |const| const.to_s.start_with?("PACKET_") }
                .find { |const| Protocol.const_get(const) == type }
      end

      def self.handle(host:, raw:, peer:)
        packet = Packet.decode(raw)
        type = packet.message.unpack1("C")

        puts "#{host.class} received #{type_to_name(type: type)}"
        pp raw

        case type
        when Protocol::PACKET_CONTROL
          handle_control_packet(host, packet, peer)
        when Protocol::PACKET_RAW
          handle_raw_packet(packet)
        when Protocol::PACKET_RELIABLE
          handle_reliable_packet(host, packet, peer)
        else
          raise NotImplementedError, "A Packet handler for #{type_to_name(type: type)}[#{type}] is not implemented!"
        end
      end

      def self.handle_control_packet(host, packet, peer)
        pkt = ControlPacket.decode(packet.message)

        case pkt.control_type
        when Protocol::CONTROL_CONNECT # TOSERVER only
          if (peer_id = host.available_peer_id)
            peer.id = peer_id
            host.peers << peer
            peer.write_queue << create_control_packet(peer: peer, control_type: Protocol::CONTROL_SET_PEER_ID, message: [peer_id].pack("n"))
            host.peer_connected(peer: peer)
          else
            host.write(
              peer: peer,
              packet: PacketHandler.create_control_packet(
                peer: peer,
                control_type: Protocol::CONTROL_DISCONNECT,
                message: "ERROR: max number of clients already connected"
              )
            )
          end

        when Protocol::CONTROL_SET_PEER_ID # TOCLIENT only
          peer.id = pkt.message.unpack1("n")
          host.connected

        when Protocol::CONTROL_DISCONNECT
          if host.is_a?(Server)
            host.peer_disconnected(peer: peer)
          else
            host.disconnected(reason: pkt.message)
          end

        when Protocol::CONTROL_HEARTBEAT
        when Protocol::CONTROL_PING
          peer.write_queue << PacketHandler.create_control_packet(
            peer: peer, control_type: Protocol::CONTROL_PONG,
            reliable: true,
            message: [Networking.milliseconds].pack("Q") # Uint64, native endian
          )
        when Protocol::CONTROL_PONG
          sent_time = pkt.message.unpack1("Q")
          difference = Networking.milliseconds - sent_time

          peer.ping = difference
        end

        nil
      end

      def self.handle_raw_packet(packet)
        RawPacket.decode(packet.message)
      end

      def self.handle_reliable_packet(host, packet, peer)
        # TODO: Preserve delivery order of reliable packets

        pkt = ReliablePacket.decode(packet.message)
        peer.write_queue << create_control_packet(
          peer: peer,
          control_type: Protocol::CONTROL_ACKNOWLEDGE,
          message: [pkt.sequence_number].pack("n")
        )

        handle(host: host, raw: pkt.message, peer: peer)
      end

      def self.create_control_packet(peer:, control_type:, message: nil, reliable: false, channel: 0)
        message_packet = nil

        if reliable
          warn "Reliable packets are not yet implemented!"
          packet = Packet.new(
            protocol_version: Protocol::PROTOCOL_VERSION,
            peer_id: peer.id,
            channel: channel,
            message: ControlPacket.new(control_type: control_type, message: message).encode
          )
          message_packet = ReliablePacket.new(sequence_number: peer.next_reliable_sequence_number, message: packet.encode)
        else
          message_packet = ControlPacket.new(control_type: control_type, message: message)
        end

        Packet.new(
          protocol_version: Protocol::PROTOCOL_VERSION,
          peer_id: peer.id,
          channel: channel,
          message: message_packet.encode
        )
      end

      def self.create_raw_packet(peer:, message:, reliable: false, channel: 0)
        message_packet = nil

        if reliable
          warn "Reliable packets are not yet implemented!"
          packet = RawPacket.new(message: message)
          message_packet = ReliablePacket.new(sequence_number: peer.next_reliable_sequence_number, message: packet.encode)
        else
          message_packet = RawPacket.new(message: message)
        end

        Packet.new(
          protocol_version: Protocol::PROTOCOL_VERSION,
          peer_id: peer.id,
          channel: channel,
          message: message_packet.encode
        )
      end
    end
  end
end
