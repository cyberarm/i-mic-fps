class IMICFPS
  class Publisher
    def self.subscribe(subscription)
      raise "Expected IMICFPS::Subscription not #{subscription.class}" unless subscription.is_a?(IMICFPS::Subscription)
      Publisher.instance.add_sub(subscription)
    end

    def self.unsubscribe(subscription)
    end

    def self.instance
      @@instance
    end

    def initialize
      @@instance = self
      EventHandler.initiate
      Component.initiate
      @events = {}
    end

    def add_sub(subscription)
      raise "Expected IMICFPS::Subscription not #{subscription.class}" unless subscription.is_a?(IMICFPS::Subscription)
      @events[subscription.event] ||= []

      @events[subscription.event] << subscription
    end

    def publish(event, context, *args)
      if subscribers = @events.dig(event)
        return unless event_handler = EventHandler.get(event)

        subscribers.each do |subscriber|
          event_handler.handle(subscriber, context, args)
        end
      end
    end
  end
end