# frozen_string_literal: true
class IMICFPS
  class HUD
    class Widget
      include CommonMethods

      # Widget margin from screen edge
      # or how much widget is pushed in
      def self.margin
        @@margin ||= 10
      end

      def self.padding=(n)
        @@padding = n
      end

      # Widget element padding
      def self.padding
        @@margin ||= 10
      end

      def self.padding=(n)
        @@padding = n
      end

      attr_reader :options
      def initialize(options = {})
        @options = options
        @player = options[:player]

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