# frozen_string_literal: true
class IMICFPS
  class EventHandler
    class Event
      attr_reader :entity, :context
      def initialize(entity:, context: nil)
        @entity, @context = entity, context
      end
    end
  end
end