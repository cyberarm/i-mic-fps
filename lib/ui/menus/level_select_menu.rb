class IMICFPS
  class LevelSelectMenu < Menu
    def setup
      title "I-MIC FPS"
      subtitle "Choose a Map"

      Dir.glob(GAME_ROOT_PATH + "/maps/*.json").map { |file| [file, MapParser.new(map_file: file)]}.each do |file, map|
        link map.metadata.name do
          push_state(
            LoadingState.new(forward: Game, map_file: file)
          )
        end
      end

      link "Back" do
        pop_state
      end
    end
  end
end
