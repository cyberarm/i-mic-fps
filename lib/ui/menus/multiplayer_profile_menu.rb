# frozen_string_literal: true

class IMICFPS
  class MultiplayerProfileMenu < Menu
    def setup
      flow(width: 1.0, height: 1.0) do
        stack(width: 0.25, height: 1.0) do
        end

        stack(width: 0.5, height: 1.0) do
          label "Profile", text_size: 100, color: Gosu::Color::BLACK, width: 1.0, text_align: :center

          flow width: 1.0 do
            link I18n.t("menus.back"), width: 0.32 do
              pop_state
            end

            button "Edit Profile", width: 0.32
            button "Log Out", width: 0.32
          end

          flow(width: 1.0, padding: 4) do
            background 0x88_222222

            image "#{GAME_ROOT_PATH}/static/logo.png", width: 64

            stack do
              label "[Clan TAG] Username", text_size: 36
              label "\"Title Badge Thingy\""
            end
          end

          flow(margin_top: 4) do
            stack do
              label "Kiil/Death Ratio"
              label "Kills"
              label "Deaths"
              label "Assists"
              label "Buildings Destroyed"
              label "Vehicles Destroyed"
              label "Repair Points"
            end

            stack margin_left: 16 do
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
