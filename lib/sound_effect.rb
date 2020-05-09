class IMICFPS
  class SoundEffect
    attr_reader :sound, :options
    def initialize(options = {})
      raise "expected Hash, got #{options.class}" unless options.is_a?(Hash)
      @options = options

      raise "sound not specified!" unless @options[:sound]

      setup
    end

    def setup
    end

    def update
    end
  end
end