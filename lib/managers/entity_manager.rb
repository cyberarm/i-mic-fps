class IMICFPS
  module EntityManager # Get included into GameState context
    def add_entity(entity)
      @collision_manager.add(entity)# Add every entity to collision manager
      @entities << entity
    end

    def find_entity(entity)
      @entities.detect {|entity| entity == entity}
    end

    def remove_entity(entity)
      ent = @entities.detect {|entity| entity == entity}
      if ent
        @collision_manager.remove(entity)
        @entities.delete(ent)
      end
    end

    def entities
      @entities
    end
  end
end
