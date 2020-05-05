class IMICFPS
  class MultiplayerMenu < Menu
    def setup
      title IMICFPS::NAME
      subtitle "Multiplayer"

      link "Online"
      link "LAN"
      link "Back" do
        pop_state
      end
    end
  end
end