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
      entity.velocity.y = other.velocity.y if other.velocity.y < entity.velocity.y && entity.velocity.y < 0
    end

    def simulate
      @collision_manager.map.entities.each do |entity|
        entity.position.x += entity.velocity.x * entity.delta_time
        entity.position.y += entity.velocity.y * entity.delta_time
        entity.position.z += entity.velocity.z * entity.delta_time

        on_ground = @collision_manager.on_ground?(entity)
        entity.velocity.x *= entity.drag
        entity.velocity.z *= entity.drag

        if on_ground
          entity.velocity.y = 0
        else
          entity.velocity.y -= @collision_manager.map.gravity * entity.delta_time if entity.manifest.physics
        end
      end
    end
  end
end