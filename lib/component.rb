# frozen_string_literal: true

class IMICFPS
  class Component
    @components = {}

    def self.get(name)
      @components[name]
    end

    def self.inherited(subclass)
      @components["__pending"] ||= []
      @components["__pending"] << subclass
    end

    def self.initiate
      return unless @components["__pending"] # Already setup

      @components["__pending"].each do |klass|
        component = klass.new
        @components[component.name] = component
      end

      @components.delete("__pending")
    end

    def initialize
      setup
    end

    def name
      string = self.class.name.split("::").last
      split = string.scan(/[A-Z][a-z]*/)

      split.map(&:downcase).join("_").to_s.to_sym
    end

    def setup
    end
  end
end
