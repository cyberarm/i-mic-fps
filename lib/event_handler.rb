# frozen_string_literal: true

class IMICFPS
  class EventHandler
    @@handlers = {}

    def self.inherited(subclass)
      @@handlers["__pending"] ||= []

      @@handlers["__pending"] << subclass
    end

    def self.initiate
      preserve = @@handlers["__pending"]
      @@handlers.clear
      @@handlers["__pending"] = preserve

      @@handlers["__pending"].each do |handler|
        instance = handler.new
        instance.handles.each do |event|
          @@handlers[event] = instance
        end
      end
    end

    def self.get(event)
      @@handlers[event]
    end

    def initialize
    end

    def handlers
      raise NotImplementedError
    end

    def handle(subscriber, context, *args)
      raise NotImplementedError
    end
  end
end
