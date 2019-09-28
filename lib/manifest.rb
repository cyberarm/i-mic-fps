class IMICFPS
  class Manifest
    attr_reader :name, :model, :collision, :collision_mesh, :collision_resolution, :physics, :scripts, :uses
    def initialize(manifest_file: nil, package: nil, name: nil)
      unless manifest_file
        raise "Entity package not specified!" unless package
        raise "Entity name not specified!" unless name
        manifest_file = "#{IMICFPS.assets_path}/#{package}/#{name}/manifest.yaml"
      end

      raise "No manifest found at: #{manifest_file}" unless  File.exist?(manifest_file)

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
      @collision_resolution = data["collision_resolution"] ? data["collision_resolution"].to_sym : :static
      @physics = data["physics"] ? data["physics"] : false
      @scripts = data["scripts"] ? parse_scripts(data["scripts"]) : []
      @uses = data["uses"] ? parse_dependencies(data["uses"]) : [] # List of entities that this Entity uses
    end

    def parse_scripts(scripts)
      list = []
      scripts.each do |script|
        list << Script.new(script, File.read("#{file_path}/scripts/#{script}.rb"))
      end

      return list
    end

    def parse_dependencies(list)
      dependencies = []
      list.each do |item|
        dependencies << Dependency.new(item["package"], item["name"])
      end

      return dependencies
    end

    def file_path
      File.expand_path("./../", @file)
    end

    Script = Struct.new(:name, :source)
    Dependency = Struct.new(:package, :name)
  end
end