# frozen_string_literal: true
class IMICFPS
  class MultiplayerServerBrowserMenu < Menu
    def setup
      @sample_games = [
        {
          host: "Host",
          game_type: "Type",
          map: "Map",
          players: "Players",
          ping: "Ping",
          source: "Source"
        },
        {
          host: "localhost:54637",
          game_type: "C&C",
          map: "Test Map",
          players: "0/16",
          ping: 48,
          source: "LAN"
        },
        {
          host: "gameserver1.example.com:5637",
          game_type: "C&C",
          map: "Islands Test Map",
          players: "14/64",
          ping: 123,
          source: "Internet"
        }
      ]

      label "Server Browser", text_size: 100
      flow width: 1.0, height: 1.0 do
        stack width: 0.25 do
          button "Host Game", width: 1.0
          button "Direct Connect", width: 1.0

          button I18n.t("menus.back"), width: 1.0, margin_top: 64 do
            pop_state
          end
        end

        stack width: 0.5, height: 1.0 do
          stack width: 1.0, height: 0.75, border_color: 0xffffffff, border_thickness: 1 do
            @sample_games.each_with_index do |game, i|
              text_size = 18
              flow width: 1.0 do
                background i.even? ? 0x55000000 : 0x55ff5500

                flow width: 0.1 do
                  label game[:game_type], text_size: text_size
                end
                flow width: 0.3 do
                  label game[:host], text_size: text_size
                end
                flow width: 0.3 do
                  label game[:map], text_size: text_size
                end
                flow width: 0.1 do
                  label game[:players], text_size: text_size
                end
                flow width: 0.1 do
                  label game[:ping], text_size: text_size
                end
                flow width: 0.1 do
                  label game[:source], text_size: text_size
                end
              end
            end
          end

          flow width: 1.0, height: 0.25 do
            label "Name"
            name = edit_line "", margin_right: 20
            button "Join", width: 0.25 do
              pp name.value
            end
          end
        end
      end
    end
  end
end