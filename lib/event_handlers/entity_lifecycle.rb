# frozen_string_literal: true

class IMICFPS
  class EventHandler
    class EntityLifeCycle < EventHandler
      def handles
        %i[create move destroy]
      end

      def handle(subscriber, context, *args)
        return unless subscriber.entity == args.first.first

        event = EventHandler::Event.new(entity: subscriber.entity, context: context)

        subscriber.trigger(event)
      end
    end
  end
end
