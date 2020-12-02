# frozen_string_literal: true

class IMICFPS
  class EventHandler
    class Input < EventHandler
      def handles
        %i[button_down button_up]
      end

      def handle(subscriber, context, *args)
        action = subscriber.args.flatten.first
        key = args.flatten.first

        event = EventHandler::Event.new(entity: subscriber.entity, context: context)

        if action.is_a?(Numeric) && action == key
          subscriber.trigger(event)
        elsif InputMapper.get(action) == key
          subscriber.trigger(event)
        end
      end
    end
  end
end
