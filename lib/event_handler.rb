class IMICFPS
  class EventHandler
    @@handlers = {}

    def self.inherited(subclass)
      @@handlers["__pending"] ||= []

      @@handlers["__pending"] << subclass
    end

    def self.initiate
      @@handlers["__pending"].each do |handler|
        instance = handler.new
        instance.handles.each do |event|
          @@handlers[event] = instance
        end
      end

      @@handlers.delete("__pending")
    end

    def self.get(event)
      @@handlers.dig(event)
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