class IMICFPS
  class HUD
    class Widget
      include CommonMethods
      attr_reader :options

      def initialize(options = {})
        @options = options
        @player = options[:player]
        @margin = 10

        setup
      end

      def setup
      end

      def draw
      end

      def update
      end
    end
  end
end