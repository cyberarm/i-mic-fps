# frozen_string_literal: true

class IMICFPS
  class AssetViewerTool
    class MainMenu < Menu
      def setup
        window.needs_cursor = true

        @manifests = []
        Dir.glob("#{GAME_ROOT_PATH}/assets/**/manifest.yaml").each do |manifest|
          begin
            @manifests << Manifest.new(manifest_file: manifest)
          rescue StandardError
            warn "Broken manifest: #{manifest}"
          end
        end

        @manifests.sort_by! { |m| m.name.downcase }



        flow(width: 1.0, height: 1.0) do
          stack(width: 0.25, height: 1.0) do
          end

          stack(width: 0.5, height: 1.0) do
            label "Asset Viewer", text_size: 100, font: BOLD_SANS_FONT, width: 1.0, text_align: :center

            link I18n.t("menus.back"), width: 1.0 do
              pop_state
            end

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
