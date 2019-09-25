class IMICFPS
  class LoadingState < Menu
    def setup
      @map = Map.new(map_file: @options[:map_file])

      title "I-MIC FPS"
      @subheading = Text.new("Loading Map: #{@map.metadata.name}", y: 100, size: 50, alignment: :center)
      @description = Text.new("Map created by: #{@map.metadata.authors.join(", ")}\n#{@map.metadata.description}", y: 180, size: 24, alignment: :center)
      @state = Text.new("Preparing...", y: window.height/2-40, size: 40, alignment: :center)
      @percentage = Text.new("0%", y: window.height - 100 + 25, size: 50, alignment: :center)

      @dummy_entity = nil
      @assets = []
      @asset_index = 0
      # add_asset(:shader, nil, "default")

      add_asset(:model, @map.terrain.package, @map.terrain.model)
      add_asset(:model, @map.skydome.package, @map.skydome.model)
      @map.entities.each do |entity|
        add_asset(:model, entity.package, entity.model)
      end

      add_asset(:model, "base", "biped")

      @act = false
      @cycled = false

      @completed_for_ms = 0
      @lock = false

      @base_color = Gosu::Color.rgb(0, 180, 180)
    end

    def draw
      super
      @subheading.draw
      @description.draw
      @state.draw


      progressbar
    end

    def update
      @percentage.text = "#{((@asset_index.to_f/@assets.count)*100.0).round}%"
      @act = true if @cycled

      if @act && (@asset_index+1 <= @assets.count)
        @act = false
        @cycled = false

        hash = @assets[@asset_index]
        case hash[:type]
        when :model
          manifest = Manifest.new(manifest_file: IMICFPS.assets_path + "/#{hash[:package]}/#{hash[:name]}/manifest.yaml")
          ModelLoader.new(manifest: manifest, entity: @dummy_entity)
        when :shader
          Shader.new(name: hash[:name], vertex: "shaders/vertex/#{hash[:name]}.glsl", fragment: "shaders/fragment/#{hash[:name]}.glsl")
        else
          warn "Unknown asset: #{hash}"
        end

        @asset_index+=1
      end

      unless @asset_index < @assets.count
        if @act && Gosu.milliseconds-@completed_for_ms > 250
          push_state(@options[:forward], map: @map)
        else
          @act = true
          @completed_for_ms = Gosu.milliseconds unless @lock
          @lock = true
        end
      else
        @state.text = "Loading #{@assets[@asset_index][:type]} #{@assets[@asset_index][:name].split('/').last}..."
        @state.x = (window.width/2)-(@state.width/2)
        @cycled = true
      end
    end

    def add_asset(type, package, name)
      @assets << {type: type, package: package, name: name}
    end

    def progressbar(x = window.width/4, y = window.height - 104)
      @percentage.draw
      progress = (@asset_index.to_f/@assets.count)*window.width/2
      height = 100

      dark_color= Gosu::Color.rgb(@base_color.red - 100, @base_color.green - 100, @base_color.blue - 100)#Gosu::Color.rgb(64, 127, 255)
      color     = Gosu::Color.rgb(@base_color.red - 50, @base_color.green - 50, @base_color.blue - 50)#Gosu::Color.rgb(0,127,127)
      color_two = Gosu::Color.rgb(@base_color.red + 50, @base_color.green + 50, @base_color.blue + 50)#Gosu::Color.rgb(64, 127, 255)

      draw_rect(x, y-2, x + window.width/4, height+4, dark_color)

      Gosu.clip_to(x, y, progress, height) do
        Gosu.draw_quad(
          x, y, color,
          x + x + window.width/4, y, color_two,
          x, y + height, color,
          x + x + window.width/4, y + height, color_two
        )
      end
    end
  end
end
