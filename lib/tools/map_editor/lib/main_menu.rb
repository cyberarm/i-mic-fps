# frozen_string_literal: true

class IMICFPS
  class MapEditorTool
    class MainMenu < Menu
      def setup
        window.needs_cursor = true

        @maps = []
        Dir.glob("#{GAME_ROOT_PATH}/maps/*.json").each do |map|
          begin
            @maps << MapParser.new(map_file: map)
          rescue StandardError
            warn "Broken map file: #{map}"
          end
        end

        @maps.sort_by! { |m| m.metadata.name.downcase }

        flow(width: 1.0, height: 1.0) do
          stack(width: 0.25, height: 1.0) do
          end

          stack(width: 0.5, height: 1.0) do
            title "Map Editor"

            flow width: 1.0 do
              link I18n.t("menus.back"), width: 0.32 do
                pop_state
              end

              button "New Map", width: 0.64
            end

            banner "Edit Map", width: 1.0, text_align: :center, text_size: 50
            flow(width: 1.0, height: 1.0) do
              @maps.each do |map|
                button map.metadata.name do
                  push_state(LoadingState, map_parser: map, forward: Editor)
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
