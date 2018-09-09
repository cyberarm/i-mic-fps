class IMICFPS
  class LoadingState < GameState
    def setup
      @header = Text.new("I-MIC FPS", y: 10, size: 100, alignment: :center)
      @subheading = Text.new("Loading Assets", y: 100, size: 50, alignment: :center)
      @state = Text.new("Preparing...", y: $window.height/2-30, size: 30, alignment: :center)
      @percentage = Text.new("0%", y: $window.height-50-15, size: 30, alignment: :center)

      @dummy_game_object = nil
      @assets = []
      @asset_index = 0
      add_asset(:obj, "objects/randomish_terrain.obj")
      add_asset(:obj, "objects/skydome.obj")
      add_asset(:obj, "objects/tree.obj")
      add_asset(:obj, "objects/biped.obj")

      @act = false
      @cycled = false
    end

    def draw
      @header.draw
      @subheading.draw
      @state.draw

      fill(Gosu::Color.rgba(127, 64, 0, 150))
      progressbar
    end

    def update
      @percentage.text = "#{((@asset_index.to_f/@assets.count)*100.0).round}%"
      @act = true if @cycled

      if @act
        @act = false
        @cycled = false

        hash = @assets[@asset_index]
        ModelLoader.new(type: hash[:type], file_path: hash[:path], game_object: @dummy_game_object)

        @asset_index+=1
      end

      unless @asset_index < @assets.count
        push_game_state(@options[:forward])
      else
        @state.text = "Loading #{@assets[@asset_index][:path].split('/').last}..."
        @cycled = true
      end
    end

    def add_asset(type, path)
      @assets << {type: type, path: path}
    end

    def progressbar
      @percentage.draw
      progress = (@asset_index.to_f/@assets.count)*$window.width
      draw_rect(0, $window.height-100, progress, 100, Gosu::Color.rgb(255,127,0))
    end
  end
end