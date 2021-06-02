# frozen_string_literal: true

class IMICFPS
  class HUD
    class ChatHistoryWidget < HUD::Widget
      def setup
        @messages = []

        @text = CyberarmEngine::Text.new(
          "",
          size: 16,
          x: Widget.horizontal_margin, y: Widget.vertical_margin, z: 45,
          border_color: Gosu::Color::BLACK,
          font: BOLD_SANS_FONT
        )

        @last_message_time = 0
        @message_interval = 1_500
      end

      def draw
        @text.draw
      end

      def update
        @text.text = @messages.last(15).map { |m| "#{m}\n" }.join

        if Gosu.milliseconds - @last_message_time >= @message_interval
          @last_message_time = Gosu.milliseconds
          @message_interval = rand(500..3_000)

          @messages << random_message
        end
      end

      def random_message
        usernames = %w[
          Cyberarm Cyber TankKiller DavyJones
        ]
        entities = [
          "Alternate Tank", "Hover Hank", "Helicopter", "Jeep"
        ]

        locations = [
          "Compass Bridge", "Compass Power Plant", "Gort Power Plant", "Gort Bridge", "Nest"
        ]

        events = %i[spot kill target message]

        messages = [
          "Need more tanks!",
          "I need 351 credits to purchase a tank",
          "I got 300"
        ]

        segments = {
          spot: [
            " spotted a <c=ffa51d2d>#{entities.sample}</c> at <c=ff26a269>#{locations.sample}</c>"
          ],
          kill: [
            " killed <c=ffa51d2d>#{usernames.sample}</c>"
          ],
          target: [
            " targeted <c=ffa51d2d>#{entities.sample} (#{usernames.sample})</c>"
          ],
          message: [
            "<c=ffe66100>: #{messages.sample}</c>"
          ]
        }

        "<c=ffe66100>#{usernames.sample}</c>#{segments[events.sample].sample}"
      end
    end
  end
end
