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

      link "Extras" do
        push_state(ExtrasMenu)
      end

      link "Exit" do
        window.close
      end

      @text = CyberarmEngine::Text.new("<b>#{IMICFPS::NAME}</b> v#{IMICFPS::VERSION} (#{IMICFPS::RELEASE_NAME})")
    end

    def draw
      super

      @text.draw
      @text.x = window.width - (@text.width + 10)
      @text.y = window.height - (@text.height + 10)
    end
  end
end
