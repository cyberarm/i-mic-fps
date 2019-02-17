class IMICFPS
  class ModelLoader
    def self.supported_models
      ["Wavefront OBJ"]
    end

    CACHE = {}

    attr_reader :model, :name, :debug_color

    def initialize(manifest_file:, game_object: nil)
      @manifest = YAML.load(File.read(manifest_file))
      pp @manifest
      @file_path = File.expand_path("./../model/", manifest_file) + "/#{@manifest["model"]}"
      @name = @manifest["name"]

      @type = File.basename(@file_path).split(".").last.to_sym
      @debug_color = Color.new(0.0, 1.0, 0.0)

      @model = nil
      @supported_models = ["OBJ"]

      unless load_model_from_cache
        case @type
        when :obj
          @model = Wavefront::Model.new(file_path: @file_path, game_object: game_object)
        else
          raise "Unsupported model type, supported models are: #{@supported_models.join(', ')}"
        end

        cache_model
      end


      return self
    end

    def load_model_from_cache
      found = false
      if CACHE[@type].is_a?(Hash)
        if CACHE[@type][@file_path]
          @model = CACHE[@type][@file_path]#.dup # Don't know why, but adding .dup improves performance with Sponza (1 fps -> 20 fps)
          # puts "Used cached model for: #{@file_path.split('/').last}"
          found = true
        end
      end

      return found
    end

    def cache_model
      CACHE[@type] = {} unless CACHE[@type].is_a?(Hash)
      CACHE[@type][@file_path] = @model
    end
  end
end
