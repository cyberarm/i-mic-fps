class IMICFPS
  class Model
    class Parser
      @@parsers = []

      def self.handles
        raise NotImplementedError, "Model::Parser#handles must return an array of file extensions that this parser supports"
      end

      def self.inherited(parser)
        @@parsers << parser
      end

      def self.find(file_type)
        found_parser = @@parsers.find do |parser|
          parser.handles.include?(file_type)
        end

        return found_parser
      end

      def initialize(model)
        @model = model
      end

      def parse
      end
    end
  end
end