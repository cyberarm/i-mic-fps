# frozen_string_literal: true

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

      @event = event
      @args = args
      @block = block
      Publisher.subscribe(self)
    end

    def trigger(event, *args)
      @block&.call(event, *args)
    end

    def self.subscribable_events
      %i[
        tick
        create move destroy
        entity_moved
        button_down button_up
        mouse_move
        interact
        player_join player_leave player_die
        pickup_item use_item drop_item
        enter_vehicle exit_vehicle
      ]
    end
  end
end
