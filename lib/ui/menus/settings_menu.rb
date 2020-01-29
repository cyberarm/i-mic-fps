class IMICFPS
  class SettingsMenu < Menu
    def setup
      title "I-MIC FPS"
      subtitle "Settings"

      link "\"There is no spoon.\""

      link "Back" do
        pop_state
      end
    end
  end
end