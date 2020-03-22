class IMICFPS
  class ExtrasMenu < Menu
    def setup
      title "I-MIC FPS"
      subtitle "Extras"

      link "Asset Viewer" do
        push_state(IMICFPS::AssetViewerTool::MainMenu)
      end

      link "Map Editor" do
        push_state(IMICFPS::MapEditorTool::MainMenu)
      end

      link "Back" do
        pop_state
      end
    end
  end
end