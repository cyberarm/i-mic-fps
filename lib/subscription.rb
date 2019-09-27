class IMICFPS
  class Subscription
    attr_reader :entity, :event, :args, :block
    def initialize(entity)
      @entity = entity

      @event = nil
      @args  = nil
      @block = nil
    end

    def method_missing(event, *args, &block)
      return unless Subscription.subscribable_events.include?(event)

      @event, @args, @block = event, args, block
      Publisher.subscribe(self)
    end

    def trigger(event, *args)
      if @block
        @block.call(event, *args)
      end
    end

    def self.subscribable_events
      [
        :tick,
        :create, :move, :destroy,
        :entity_moved,
        :button_down, :button_up,
        :mouse_move,
        :interact,
        :player_join, :player_leave, :player_die,
        :pickup_item, :use_item, :drop_item,
        :enter_vehicle, :exit_vehicle,
      ]
    end
  end
end