class IMICFPS
  class MainMenu < Menu
    def setup
      title "I-MIC FPS"
      link "Single Player" do
        push_state(LoadingState.new(forward: Game))
      end
      link "Settings" do
        # push_game_state(SettingsMenu)
      end
      link "Exit" do
        window.close
      end
    end
  end
end