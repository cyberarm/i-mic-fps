class IMICFPS
  class Map
    attr_reader :metadata, :terrain, :skydome, :entities, :spawnpoints
    attr_reader :assets, :missing_assets
    def initialize(map_file:)
      @metadata    = Map::MetaData.new
      @terrain     = Map::Entity.new
      @skydome     = Map::Entity.new
      @entities    = []
      @spawnpoints = []

      @assets = []
      @missing_assets = []

      parse(map_file)
    end

    def parse(file)
      data = JSON.parse(File.read(file))

      if section = data["metadata"]
        @metadata.name        = section["name"]
        @metadata.gamemode    = section["gamemode"]
        @metadata.authors     = section["authors"]
        @metadata.datetime    = Time.parse(section["datetime"])
        @metadata.thumbnail   = section["thumbnail"] # TODO: convert thumbnail to Image
        @metadata.description = section["description"]
      else
        raise "Map metadata is missing!"
      end

      if section = data["terrain"]
        @terrain.package     = section["package"]
        @terrain.model       = section["model"]
        @terrain.position    = Vector.new
        @terrain.orientation = Vector.new
        @terrain.scale       = 1.0
        @terrain.water_level = section["water_level"]
      else
        raise "Map terrain data is missing!"
      end

      if section = data["skydome"]
        @skydome.package     = section["package"]
        @skydome.model       = section["model"]
        @skydome.position    = Vector.new
        @skydome.orientation = Vector.new
        @skydome.scale       = section["scale"] ? section["scale"] : 1.0
      else
        raise "Map skydome data is missing!"
      end

      if section = data["entities"]
        section.each do |ent|
          entity = Map::Entity.new
          entity.package  = ent["package"]
          entity.model    = ent["model"]
          entity.position = Vector.new(
            ent["position"]["x"],
            ent["position"]["y"],
            ent["position"]["z"]
          )
          entity.orientation = Vector.new(
            ent["orientation"]["x"],
            ent["orientation"]["y"],
            ent["orientation"]["z"]
          )
          entity.scale = ent["scale"]
          entity.scripts = ent["scripts"]

          @entities << entity
        end
      else
        raise "Map has no entities!"
      end

      if section = data["spawnpoints"]
        section.each do |point|
          spawnpoint = SpawnPoint.new
          spawnpoint.team = point["team"]
          spawnpoint.position = Vector.new(
            point["position"]["x"],
            point["position"]["y"],
            point["position"]["z"]
          )
          spawnpoint.orientation = Vector.new(
            point["orientation"]["x"],
            point["orientation"]["y"],
            point["orientation"]["z"]
          )

          @spawnpoints << spawnpoint
        end
      else
        raise "Map has no spawnpoints!"
      end
    end

    MetaData   = Struct.new(:name, :gamemode, :authors, :datetime, :thumbnail, :description)
    Entity     = Struct.new(:package, :model, :position, :orientation, :scale, :water_level, :scripts)
    SpawnPoint = Struct.new(:team, :position, :orientation)
  end
end