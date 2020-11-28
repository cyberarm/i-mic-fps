class IMICFPS
  class MultiplayerMenu < Menu
    def setup
      title IMICFPS::NAME
      subtitle "Multiplayer"

      link "Quick Join"
      link "Server Browser" do
        push_state(MultiplayerServerBrowserMenu)
      end
      link "Profile" do
        push_state(MultiplayerProfileMenu)
      end
      link "Back" do
        pop_state
      end
    end
  end
end