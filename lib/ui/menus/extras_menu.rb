# frozen_string_literal: true

class IMICFPS
  class ExtrasMenu < Menu
    def setup
      title I18n.t("menus.extras")

      link "Asset Viewer" do
        push_state(IMICFPS::AssetViewerTool::MainMenu)
      end

      link "Map Editor" do
        push_state(IMICFPS::MapEditorTool::MainMenu)
      end

      link I18n.t("menus.back"), margin_top: 25 do
        pop_state
      end
    end
  end
end
