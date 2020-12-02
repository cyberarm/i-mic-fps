class IMICFPS
  class LoadingState < Menu
    def setup
      window.needs_cursor = false
      if @options[:map_file]
        @map_parser = MapParser.new(map_file: @options[:map_file])
      elsif @options[:map_parser]
        @map_parser = @options[:map_parser]
      else
        raise "Unable to load map, missing :map_file or :map_parser"
      end

      title IMICFPS::NAME
      @subheading = Text.new("Loading Map: #{@map_parser.metadata.name}", y: 100, size: 50, alignment: :center, font: SANS_FONT)
      @description = Text.new("Map created by: #{@map_parser.metadata.authors.join(", ")}\n#{@map_parser.metadata.description}", y: 180, size: 24, alignment: :center, font: SANS_FONT)
      @state = Text.new("Preparing...", y: window.height/2-40, size: 40, alignment: :center, font: SANS_FONT)
      @percentage = Text.new("0%", y: window.height - 100 + 25, size: 50, alignment: :center, font: SANS_FONT)

      @dummy_entity = nil
      @assets = []
      @asset_index = 0

      add_asset(:model, @map_parser.terrain.package, @map_parser.terrain.name)
      add_asset(:model, @map_parser.skydome.package, @map_parser.skydome.name)
      @map_parser.entities.each do |entity|
        add_asset(:model, entity.package, entity.name)
      end

      add_asset(:model, "base", "character")

      @act = false
      @cycled = false

      @completed_for_ms = 0
      @lock = false

      @primary_color = Gosu::Color.rgba(0, 180, 180, 200)
      @accent_color = Gosu::Color.rgba(0, 90, 90, 200)
    end

    def draw
      super
      @subheading.draw
      @description.draw
      @state.draw


      progressbar
    end

    def update
      super
      @percentage.text = "#{((@asset_index.to_f / @assets.count) * 100.0).round}%"
      @act = true if @cycled

      if @act && (@asset_index + 1 <= @assets.count)
        @act = false
        @cycled = false

        hash = @assets[@asset_index]
        case hash[:type]
        when :model
          ModelCache.find_or_cache(manifest: hash[:manifest])
        when :shader
          if window.config.get(:debug_options, :use_shaders)
            shader = Shader.new(name: hash[:name], includes_dir: "shaders/include", vertex: "shaders/vertex/#{hash[:name]}.glsl", fragment: "shaders/fragment/#{hash[:name]}.glsl")
          else
            warn "Skipping shader: #{hash[:name]}..."
          end
        else
          warn "Unknown asset: #{hash}"
        end

        @asset_index += 1
      end

      unless @asset_index < @assets.count
        if @act && Gosu.milliseconds-@completed_for_ms > 250
          push_state(@options[:forward], map_parser: @map_parser)
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
      case type
      when :model
        manifest = Manifest.new(manifest_file: IMICFPS.assets_path + "/#{package}/#{name}/manifest.yaml")
        add_required_assets(manifest)
        @assets << {type: type, manifest: manifest, package: package, name: name}
      when :shader
        @assets << {type: type, manifest: manifest, package: package, name: name}
      else
        raise TypeError "Unable to load asset of type #{type}"
      end
    end

    def add_required_assets(manifest)
      manifest.uses.each do |dependency|
        known = @assets.detect {|asset| asset[:package] == dependency.package && asset[:name] == dependency.name}
        unless known
          add_asset(:model, dependency.package, dependency.name)
        end
      end
    end

    def progressbar(x = window.width/4, y = window.height - 104)
      @percentage.draw
      progress = (@asset_index.to_f/@assets.count)*window.width/2
      height = 100

      dark_color= Gosu::Color.rgb(@primary_color.red - 100, @primary_color.green - 100, @primary_color.blue - 100)#Gosu::Color.rgb(64, 127, 255)
      color     = Gosu::Color.rgb(@primary_color.red - 50, @primary_color.green - 50, @primary_color.blue - 50)#Gosu::Color.rgb(0,127,127)
      color_two = Gosu::Color.rgb(@primary_color.red + 50, @primary_color.green + 50, @primary_color.blue + 50)#Gosu::Color.rgb(64, 127, 255)

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
