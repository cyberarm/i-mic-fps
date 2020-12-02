class IMICFPS
  module EntityManager # Get included into GameState context
    def add_entity(entity)
      @collision_manager.add(entity) if @collision_manager && entity.manifest.collision# Add every entity to collision manager
      Publisher.instance.publish(:create, nil, entity)
      @entities << entity
    end

    def insert_entity(package, name, position, orientation, data = {})
      ent = MapParser::Entity.new(package, name, position, orientation, Vector.new(1, 1, 1))
      add_entity(IMICFPS::Entity.new(map_entity: ent, manifest: Manifest.new(package: package, name: name)))
    end

    def find_entity(entity)
      @entities.detect { |e| e == entity }
    end

    def find_entity_by(name:)
      @entities.detect { |entity| entity.name == name }
    end

    def remove_entity(entity)
      return unless (ent = @entities.detect { |e| e == entity })

      @collision_manager.remove(entity) if @collision_manager && entity.manifest.collision
      @publisher.publish(:destroy, nil, entity)
      @entities.delete(ent)
    end

    def entities
      @entities
    end

    def insert_particle_emitter(position, texture)
    end
  end
end
