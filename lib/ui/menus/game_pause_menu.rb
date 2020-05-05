class IMICFPS
  class GamePauseMenu < Menu
    def setup
      @bar_alpha = 50
      title IMICFPS::NAME
      subtitle "Paused"

      link "Resume" do
        pop_state
      end

      link "Settings" do
        push_state(SettingsMenu)
      end

      link "Leave" do
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
