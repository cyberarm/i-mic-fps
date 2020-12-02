# frozen_string_literal: true
class IMICFPS
  class Component
    COMPONENTS = {}

    def self.get(name)
      COMPONENTS.dig(name)
    end

    def self.inherited(subclass)
      COMPONENTS["__pending"] ||= []
      COMPONENTS["__pending"] << subclass
    end

    def self.initiate
      return unless COMPONENTS.dig("__pending") # Already setup

      COMPONENTS["__pending"].each do |klass|
        component = klass.new
        COMPONENTS[component.name] = component
      end

      COMPONENTS.delete("__pending")
    end

    def initialize
      setup
    end

    def name
      string = self.class.name.split("::").last
      split = string.scan(/[A-Z][a-z]*/)

      component_name = "#{split.map { |s| s.downcase }.join("_")}".to_sym

      return component_name
    end

    def setup
    end
  end
end