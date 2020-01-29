class IMICFPS
  class GamePauseMenu < Menu
    def setup
      title "I-MIC FPS"
      subtitle "Paused"

      link "Resume" do
        pop_state
      end

      link "Disconnect" do
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