# frozen_string_literal: true

class IMICFPS
  module Scripting
    class SandBox
      include Scripting
      def initialize(entity:, script:)
        @entity = entity
        @script = script.name

        execute(script.source) if source_safe?(script.source)
      end

      def source_safe?(_source)
        true # TODO: implement whitelisting/safety checks
      end

      def execute(source)
        instance_eval(source)
      end

      attr_reader :entity
    end
  end
end
