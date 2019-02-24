class IMICFPS
  class PhysicsManager
    def initialize(collision_manager:)
      @collision_manager = collision_manager
    end

    def update
      @collision_manager.collisions.each do |entity, versus|
        versus.each do |versus|
          resolve(entity, other)
        end
      end
    end

    def resolve(entity, other)
    end
  end
end