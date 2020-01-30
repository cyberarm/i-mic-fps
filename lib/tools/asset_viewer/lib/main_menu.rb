class IMICFPS
  class AssetViewerTool
    class MainMenu < CyberarmEngine::GuiState
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

        flow(margin: 10) do
          @manifests.each do |manifest|
            button manifest.name do
              push_state(TurnTable, manifest: manifest)
            end
          end
        end

        button "Exit", margin_top: 25 do
          window.close
        end
      end
    end
  end
end