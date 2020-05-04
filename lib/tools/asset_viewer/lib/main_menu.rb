class IMICFPS
  class AssetViewerTool
    class MainMenu < CyberarmEngine::GuiState
      include CommonMethods
      def setup
        window.needs_cursor = true

        label "#{IMICFPS::NAME}", text_size: 50
        label "Asset Viewer", text_size: 28

        @manifests = []
        Dir.glob(GAME_ROOT_PATH + "/assets/**/manifest.yaml").each do |manifest|
          begin
            @manifests << Manifest.new(manifest_file: manifest)
          rescue
            warn "Broken manifest: #{manifest}"
          end
        end

        @manifests.sort_by! { |m| m.name.downcase }

        button "Back", margin_bottom: 25 do
          pop_state
        end

        flow(margin: 10) do
          @manifests.each do |manifest|
            button manifest.name do
              push_state(TurnTable, manifest: manifest)
            end
          end
        end
      end

      def draw
        menu_background(Menu::PRIMARY_COLOR, Menu::ACCENT_COLOR, Menu::BAR_COLOR_STEP, Menu::BAR_ALPHA, Menu::BAR_SIZE, Menu::BAR_SLOPE)
        super
      end

      def update
        super

        window.needs_cursor = true
      end
    end
  end
end