# frozen_string_literal: true

class IMICFPS
  class GamePauseMenu < Menu
    def setup
      @bar_alpha = 50
      title "Paused"

      link "Resume" do
        pop_state
      end

      link I18n.t("menus.settings") do
        push_state(SettingsMenu)
      end

      link I18n.t("menus.leave"), margin_top: 25 do
        push_state(MainMenu)
      end
    end

    def draw
      previous_state.draw
      Gosu.flush

      super
    end
  end
end
