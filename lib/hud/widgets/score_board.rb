# frozen_string_literal: true

class IMICFPS
  class HUD
    class ScoreBoardWidget < HUD::Widget
      def setup
        @usernames = Array("AAAA".."zzzz") # "Adran".."Zebra")

        @text = CyberarmEngine::Text.new(
          "",
          size: 16,
          x: Widget.horizontal_margin, y: Widget.vertical_margin, z: 45,
          border: true,
          border_color: Gosu::Color::BLACK,
          font: BOLD_SANS_FONT
        )

        set_text
      end

      def draw
        @text.draw
      end

      def update
        @text.x = window.width - (@text.markup_width + Widget.horizontal_margin)
      end

      def generate_random_data
        number_of_players = rand(2..32)

        data = {
          teams: [
            {
              name: "Compass",
              credits: 0,
              score: 0
            },
            {
              name: "Gort",
              credits: 0,
              score: 0
            }
          ],
          players: []
        }

        number_of_players.times do |i|
          data[:players] << {
            team: i.even? ? 0 : 1,
            username: @usernames.sample,
            score: rand(0..29_999),
            credits: rand(0..9_999)
          }
        end

        data[:teams][0][:credits] = data[:players].select { |player| (player[:team]).zero? }.map { |player| player[:credits] }.reduce(0, :+)
        data[:teams][0][:score] = data[:players].select { |player| (player[:team]).zero? }.map { |player| player[:score] }.reduce(0, :+)

        data[:teams][1][:credits] = data[:players].select { |player| player[:team] == 1 }.map { |player| player[:credits] }.reduce(0, :+)
        data[:teams][1][:score] = data[:players].select { |player| player[:team] == 1 }.map { |player| player[:score] }.reduce(0, :+)

        data[:teams] = data[:teams].sort_by { |team| team[:score] }.reverse
        data[:players] = data[:players].sort_by { |player| player[:score] }.reverse

        data
      end

      def set_text
        team_header = %i[name credits score]
        player_header = %i[username credits score]

        data = generate_random_data

        text = ""
        text += "#   Team   Credits   Score\n"
        data[:teams].each_with_index do |team, i|
          i += 1
          text += "<c=#{team[:name] == 'Compass' ? 'ffe66100' : 'ffa51d2d'}>#{i}   #{team[:name]}   #{i.even? ? team[:credits] : '-----'}   #{team[:score]}</c>\n"
        end

        text += "\n"

        text += "#   Name   Credits   Score\n"
        data[:players].each_with_index do |player, i|
          i += 1
          text += "<c=#{player[:team].even? ? 'ffe66100' : 'ffa51d2d'}>#{i}   #{player[:username]}   #{player[:team].even? ? player[:credits] : '-----'}   #{player[:score]}</c>\n"
        end

        @text.text = text
      end
    end
  end
end
