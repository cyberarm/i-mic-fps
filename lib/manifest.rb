class IMICFPS
  class Manifest
    attr_reader :name, :model, :collision, :collision_mesh, :scripts, :uses
    def initialize(manifest_file: nil, package: nil, model: nil)
      unless manifest_file
        raise "Entity package not specified!" unless package
        raise "Entity model not specified!" unless model
        manifest_file = "#{IMICFPS.assets_path}/#{package}/#{model}/manifest.yaml"
      end

      @file = manifest_file
      parse(manifest_file)
    end

    def parse(file)
      data = YAML.load(File.read(file))

      # required
      @name = data["name"]
      @model = data["model"]

      # optional
      @collision = data["collision"] ? data["collision"] : nil
      @collision_mesh = data["collision_mesh"] ? data["collision_mesh"] : nil
      @scripts = data["scripts"] ? data["scripts"] : []
      @uses = data["uses"] ? data["uses"] : [] # List of entities that this Entity uses
    end

    def file_path
      File.expand_path("./../", @file)
    end
  end
end