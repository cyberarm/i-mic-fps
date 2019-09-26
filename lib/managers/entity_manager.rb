class IMICFPS
  module EntityManager # Get included into GameState context
    def add_entity(entity)
      @collision_manager.add(entity)# Add every entity to collision manager
      @publisher.publish(:create, self, entity)
      @entities << entity
    end

    def insert_entity(package, name, position, orientation, data = {})
      ent = Map::Entity.new(package, name, position, orientation, Vector.new(1,1,1))
      add_entity(IMICFPS::Entity.new(map_entity: ent, manifest: Manifest.new(package: package, name: name)))
    end

    def find_entity(entity)
      @entities.detect {|entity| entity == entity}
    end

    def remove_entity(entity)
      ent = @entities.detect {|entity| entity == entity}
      if ent
        @collision_manager.remove(entity)
        @publisher.publish(:destroy, self, entity)
        @entities.delete(ent)
      end
    end

    def entities
      @entities
    end
  end
end
