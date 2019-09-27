class IMICFPS
  class EventHandler
    class Input < EventHandler
      def handles
        [:button_down, :button_up]
      end

      def handle(subscriber, context, *args)
        action = subscriber.args.flatten.first
        key = args.flatten.first

        event = EventHandler::Event.new(entity: subscriber.entity, context: context)

        if action.is_a?(Numeric) && action == key
          subscriber.trigger(event)
        else
          if InputMapper.get(action) == key
            subscriber.trigger(event)
          end
        end
      end
    end
  end
end