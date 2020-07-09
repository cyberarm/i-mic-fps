class IMICFPS
  class MapEditorTool
    class MainMenu < Menu
      def setup
        window.needs_cursor = true

        label "#{IMICFPS::NAME}", text_size: 50
        label "Map Editor", text_size: 28

        @maps = []
        Dir.glob(GAME_ROOT_PATH + "/maps/*.json").each do |map|
          begin
            @maps << MapParser.new(map_file: map)
          rescue
            warn "Broken map file: #{map}"
          end
        end

        @maps.sort_by! { |m| m.metadata.name.downcase }

        flow(width: 1.0, height: 1.0) do
          stack(width: 0.25, height: 1.0) do
            button "New Map", width: 1.0

            button "Back", margin_top: 64, width: 1.0 do
              pop_state
            end
          end

          stack(width: 0.5, height: 1.0) do
            label "Edit Map"
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