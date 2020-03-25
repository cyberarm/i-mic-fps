class IMICFPS
  class ModelCache
    CACHE = {}

    attr_reader :model, :name, :debug_color

    def initialize(manifest:, entity: nil)
      @name = manifest.name
      @model_file = model_file = manifest.file_path + "/model/#{manifest.model}"

      @type = File.basename(@model_file).split(".").last.to_sym
      @debug_color = Color.new(0.0, 1.0, 0.0)

      @model = nil

      unless load_model_from_cache
        @model = IMICFPS::Model.new(file_path: @model_file)

        cache_model
      end

      return self
    end

    def load_model_from_cache
      found = false
      if CACHE[@type].is_a?(Hash)
        if CACHE[@type][@model_file]
          @model = CACHE[@type][@model_file]#.dup # Don't know why, but adding .dup improves performance with Sponza (1 fps -> 20 fps)
          puts "Used cached model for: #{@model_file.split('/').last}" if $window.config.get(:debug_options, :stats)
          found = true
        end
      end

      return found
    end

    def cache_model
      CACHE[@type] = {} unless CACHE[@type].is_a?(Hash)
      CACHE[@type][@model_file] = @model
    end
  end
end