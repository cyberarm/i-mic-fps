class IMICFPS
  class EventHandler
    class EntityMoved < EventHandler
      def handles
        [:entity_moved]
      end

      def handle(subscriber, context, *args)
        event = EventHandler::Event.new(entity: context)

        subscriber.trigger(event)
      end
    end
  end
end