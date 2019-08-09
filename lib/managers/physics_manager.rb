class IMICFPS
  class PhysicsManager
    def initialize(collision_manager:)
      @collision_manager = collision_manager
    end

    def update
      @collision_manager.collisions.each do |entity, versus|
        versus.each do |other|
          resolve(entity, other)
        end
      end

      simulate
    end

    def resolve(entity, other)
      if other.is_a?(Terrain)
        entity.velocity.y = 0 if entity.velocity.y < 0
      else
        entity.velocity.y = other.velocity.y if other.velocity.y < entity.velocity.y && entity.velocity.y < 0
      end
    end

    def simulate
      @collision_manager.game_state.entities.each do |entity|
        entity.velocity.x *= entity.drag
        entity.velocity.z *= entity.drag

        entity.position.x += entity.velocity.x * entity.delta_time
        entity.position.y += entity.velocity.y * entity.delta_time
        entity.position.z += entity.velocity.z * entity.delta_time
      end
    end
  end
end