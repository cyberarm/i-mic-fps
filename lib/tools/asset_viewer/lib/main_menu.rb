class IMICFPS
  class AssetViewerTool
    class MainMenu < Menu
      def setup
        window.needs_cursor = true

        @manifests = []
        Dir.glob(GAME_ROOT_PATH + "/assets/**/manifest.yaml").each do |manifest|
          begin
            @manifests << Manifest.new(manifest_file: manifest)
          rescue
            warn "Broken manifest: #{manifest}"
          end
        end

        @manifests.sort_by! { |m| m.name.downcase }

        label "#{IMICFPS::NAME}", text_size: 100, color: Gosu::Color::BLACK
        label "Asset Viewer", text_size: 50

        flow(width: 1.0, height: 1.0) do
          stack(width: 0.25, height: 1.0) do
            button "Back", width: 1.0 do
              pop_state
            end
          end

          stack(width: 0.5, height: 1.0) do
            flow(width: 1.0, height: 1.0) do
              @manifests.each do |manifest|
                button manifest.name do
                  push_state(TurnTable, manifest: manifest)
                end
              end
            end
          end
        end
      end

      def update
        super

        window.needs_cursor = true
      end
    end
  end
end