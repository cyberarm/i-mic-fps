# frozen_string_literal: true

class IMICFPS
  class LevelSelectMenu < Menu
    def setup
      title I18n.t("menus.singleplayer")
      subtitle "Choose a Map"

      Dir.glob("#{GAME_ROOT_PATH}/maps/*.json").map { |file| [file, MapParser.new(map_file: file)] }.each do |file, map|
        next unless map.metadata.gamemode

        link map.metadata.name do
          push_state(
            LoadingState.new(forward: Game, map_file: file)
          )
        end
      end

      link I18n.t("menus.back"), margin_top: 25 do
        pop_state
      end
    end
  end
end
