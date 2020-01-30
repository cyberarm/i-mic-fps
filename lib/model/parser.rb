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

      def self.supported_formats
        @@parsers.map { |parser| parser.handles }.flatten.map { |s| ".#{s}" }.join(", ")
      end

      def initialize(model)
        @model = model
      end

      def parse
      end

      def change_object(name)
        @model.objects << Model::ModelObject.new(name)
        @model.current_object = @model.objects.last
      end

      def set_material(name)
        @model.current_material = name
      end

      def add_material(name, material)
        @model.materials[name] = material
      end

      def current_material
        @model.materials[@model.current_material]
      end
    end
  end
end