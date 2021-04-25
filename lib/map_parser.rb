# frozen_string_literal: true

class IMICFPS
  class MapParser
    attr_reader :metadata, :terrain, :skydome, :lights, :entities, :spawnpoints, :assets, :missing_assets

    def initialize(map_file:)
      @metadata    = MapParser::MetaData.new
      @terrain     = MapParser::Entity.new
      @skydome     = MapParser::Entity.new
      @lights      = []
      @entities    = []
      @spawnpoints = []

      @assets = []
      @missing_assets = []

      parse(map_file)
    end

    def light_type(type)
      case type.downcase.strip
      when "directional"
        CyberarmEngine::Light::DIRECTIONAL
      when "spot"
        CyberarmEngine::Light::SPOT
      else
        CyberarmEngine::Light::POINT
      end
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
        warn "Map metadata is missing!"
      end

      if section = data["terrain"]
        @terrain.package     = section["package"]
        @terrain.name        = section["name"]
        @terrain.position    = Vector.new
        @terrain.orientation = Vector.new
        if section["scale"]
          if section["scale"].is_a?(Hash)
            @terrain.scale = Vector.new(
              section["scale"]["x"],
              section["scale"]["y"],
              section["scale"]["z"]
            )
          else
            scale = Float(section["scale"])
            @terrain.scale = Vector.new(scale, scale, scale)
          end
        else
          @terrain.scale = Vector.new(1, 1, 1)
        end
        @terrain.water_level = section["water_level"]
      else
        warn "Map terrain data is missing!"
      end

      if section = data["skydome"]
        @skydome.package     = section["package"]
        @skydome.name        = section["name"]
        @skydome.position    = Vector.new
        @skydome.orientation = Vector.new
        if section["scale"]
          if section["scale"].is_a?(Hash)
            @skydome.scale = Vector.new(
              section["scale"]["x"],
              section["scale"]["y"],
              section["scale"]["z"]
            )
          else
            scale = Float(section["scale"])
            @skydome.scale = Vector.new(scale, scale, scale)
          end
        else
          @skydome.scale = Vector.new(1, 1, 1)
        end
      else
        warn "Map skydome data is missing!"
      end

      if section = data["lights"]
        section.each do |l|
          light = MapParser::Light.new
          light.type = light_type(l["type"])
          light.position = Vector.new(
            l["position"]["x"],
            l["position"]["y"],
            l["position"]["z"]
          )
          light.diffuse = Color.new(
            l["diffuse"]["red"],
            l["diffuse"]["green"],
            l["diffuse"]["blue"]
          )
          light.ambient = Color.new(
            l["ambient"]["red"],
            l["ambient"]["green"],
            l["ambient"]["blue"]
          )
          light.specular = Color.new(
            l["specular"]["red"],
            l["specular"]["green"],
            l["specular"]["blue"]
          )
          light.intensity = l["intensity"]

          @lights << light
        end
      end

      if section = data["entities"]
        section.each do |ent|
          entity = MapParser::Entity.new
          entity.package  = ent["package"]
          entity.name     = ent["name"]
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
          if ent["scale"].is_a?(Hash)
            entity.scale = Vector.new(
              ent["scale"]["x"],
              ent["scale"]["y"],
              ent["scale"]["z"]
            )
          else
            scale = Float(ent["scale"])
            entity.scale = Vector.new(scale, scale, scale)
          end
          entity.scripts = ent["scripts"]

          @entities << entity
        end
      else
        warn "Map has no entities!"
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
        warn "Map has no spawnpoints!"
      end
    end

    MetaData   = Struct.new(:name, :gamemode, :authors, :datetime, :thumbnail, :description)
    Light      = Struct.new(:type, :position, :diffuse, :ambient, :specular, :intensity)
    Entity     = Struct.new(:package, :name, :position, :orientation, :scale, :water_level, :scripts)
    SpawnPoint = Struct.new(:team, :position, :orientation)
  end
end
