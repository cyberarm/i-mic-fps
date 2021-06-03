# frozen_string_literal: true

class IMICFPS
  class SinglePlayerMenu < Menu
    def setup
      title I18n.t("menus.singleplayer")

      link "Tutorial", enabled: false, tip: "No tutorial implemented, yet..."

      link "Campaign", enabled: false, tip: "No campaign, yet..."

      link "Multiplayer Practice" do
        push_state(LevelSelectMenu)
      end

      link I18n.t("menus.back"), margin_top: 25 do
        pop_state
      end
    end
  end
end
