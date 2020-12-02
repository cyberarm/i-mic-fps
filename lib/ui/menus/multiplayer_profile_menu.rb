# frozen_string_literal: true
class IMICFPS
  class MultiplayerProfileMenu < Menu
    def setup
      label "Profile", text_size: 100, color: Gosu::Color::BLACK

      flow(width: 1.0, height: 1.0) do
        stack(width: 0.25, height: 1.0) do
          button "Edit Profile", width: 1.0
          button "Log Out", width: 1.0
          button I18n.t("menus.back"), width: 1.0, margin_top: 64 do
            pop_state
          end
        end
        stack(width: 0.5, height: 1.0) do
          flow(width: 1.0, padding: 4) do
            background 0x88_222222

            image "#{GAME_ROOT_PATH}/static/logo.png", width: 64

            stack do
              label "[Clan TAG] Username", text_size: 36
              label "\"Title Badge Thingy\""
            end
          end

          flow(margin_top: 4, margin_right: 4) do
            stack do
              label "Kiil/Death Ratio"
              label "Kills"
              label "Deaths"
              label "Assists"
              label "Buildings Destroyed"
              label "Vehicles Destroyed"
              label "Repair Points"
            end

            stack do
              label "0.72"
              label "21"
              label "28"
              label "14"
              label "111"
              label "41"
              label "4,451"
            end
          end
        end
      end
    end
  end
end