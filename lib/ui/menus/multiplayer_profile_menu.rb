# frozen_string_literal: true

class IMICFPS
  class MultiplayerProfileMenu < Menu
    def setup
      flow(width: 1.0, height: 1.0) do
        stack(width: 0.25, height: 1.0) do
        end

        stack(width: 0.5, height: 1.0) do
          title "Profile"

          flow width: 1.0 do
            link I18n.t("menus.back"), width: 0.333 do
              pop_state
            end

            button "Edit Profile", width: 0.333
            button "Log Out", width: 0.333
          end

          flow(width: 1.0, padding: 4) do
            background 0x88_222222

            image "#{GAME_ROOT_PATH}/static/logo.png", width: 64

            stack do
              tagline "[Clan TAG] Username", text_size: 36
              tagline "\"Title Badge Thingy\""
            end
          end

          flow(margin_top: 4, width: 1.0) do
            stack do
              tagline "Kiil/Death Ratio"
              tagline "Kills"
              tagline "Deaths"
              tagline "Assists"
              tagline "Buildings Destroyed"
              tagline "Vehicles Destroyed"
              tagline "Repair Points"
            end

            stack margin_left: 16 do
              tagline "0.75"
              tagline "21"
              tagline "28"
              tagline "14"
              tagline "111"
              tagline "41"
              tagline "4,451"
            end
          end
        end
      end
    end
  end
end
