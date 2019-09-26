class IMICFPS
  class EventHandler
    class Event
      attr_reader :entity, :context, :map, :player
      def initialize(entity:, context: nil, map: $window.current_state, player: nil)
        @entity, @context, @map, @player = entity, context, map, player
      end
    end
  end
end