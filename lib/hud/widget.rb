class IMICFPS
  class HUD
    class Widget
      include CommonMethods
      attr_reader :options

      def initialize(options = {})
        @options = options
        @player = options[:player]

        # Widget margin from screen edge
        # or how much widget is pushed in
        @margin = 10

        # Widget element padding
        @padding = 10

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