# frozen_string_literal: true

class IMICFPS
  class HUD
    class Widget
      include CommonMethods

      # Widget margin from screen edge
      # or how much widget is pushed in
      def self.vertical_margin
        @@vertical_margin ||= 36
      end

      def self.vertical_margin=(n)
        @@vertical_margin = n
      end

      def self.horizontal_margin
        @@horizontal_margin ||= 10
      end

      def self.horizontal_margin=(n)
        @@horizontal_margin = n
      end

      # Widget element padding
      def self.vertical_padding
        @@vertical_padding ||= 10
      end

      def self.vertical_padding=(n)
        @@vertical_padding = n
      end

      def self.horizontal_padding
        @@horizontal_padding ||= 10
      end

      def self.horizontal_padding=(n)
        @@horizontal_padding = n
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

      def button_down(id)
      end

      def button_up(id)
      end

      def hijack_input!
        $window.input_hijack = self
      end

      def release_input!
        $window.input_hijack = nil
      end
    end
  end
end
