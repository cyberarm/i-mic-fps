class IMICFPS
  module ModelCache
    CACHE = {}

    def self.find_or_cache(manifest:)
      model_file = manifest.file_path + "/model/#{manifest.model}"

      type = File.basename(model_file).split(".").last.to_sym

      if model = load_model_from_cache(type, model_file)
        return model
      else
        model = IMICFPS::Model.new(file_path: model_file)
        cache_model(type, model_file, model)

        return model
      end
    end

    def self.load_model_from_cache(type, model_file)
      if CACHE[type].is_a?(Hash)
        if CACHE[type][model_file]
          puts "Used cached model for: #{model_file.split('/').last}" if $window.config.get(:debug_options, :stats)
          return CACHE[type][model_file]
        end
      end

      return false
    end

    def self.cache_model(type, model_file, model)
      CACHE[type] = {} unless CACHE[type].is_a?(Hash)
      CACHE[type][model_file] = model
    end
  end
end
