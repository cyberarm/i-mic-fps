class IMICFPS
  class MapEditorTool
    class MainMenu < CyberarmEngine::GuiState
      include CommonMethods

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

        button "Back", margin_bottom: 25 do
          pop_state
        end

        button "New Map"

        label ""
        label "Edit Map"
        flow(margin: 10) do
          @maps.each do |map|
            button map.metadata.name do
              push_state(LoadingState, map_parser: map, forward: Editor)
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