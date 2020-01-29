class IMICFPS
  class MainMenu < Menu
    def setup
      title "I-MIC FPS"
      link "Single Player" do
        push_state(LevelSelectMenu)
        # push_state(LoadingState.new(forward: Game, map_file: GAME_ROOT_PATH + "/maps/test_map.json"))
      end
      link "Settings" do
        push_state(SettingsMenu)
      end
      link "Exit" do
        window.close
      end
    end
  end
end
