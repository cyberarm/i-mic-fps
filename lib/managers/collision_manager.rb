class IMICFPS
  class CollisionManager
    def initialize(game_state:)
      @game_state = game_state
      @aabb_tree  = AABBTree.new
    end

    def add(entity)
      @aabb_tree.add(entity.normalized_bounding_box, entity)
    end

    def remove(entity)
      @aabb_tree.remove(entity)
    end

    def lazy_check_collisions
      # Expensive AABB collision detection
      @game_state.entities.each do |entity|
        @game_state.entities.each do |other|
          next if entity == other
          next if entity.is_a?(Terrain) || other.is_a?(Terrain)

          if entity.intersect(other)
            entity.debug_color = Color.new(1.0,0.0,0.0)
            other.debug_color = Color.new(1.0,0.0,0.0)

           # @game_state.entities.delete(entity) unless entity.is_a?(Player)
            # puts "#{entity} is intersecting #{b}" if entity.is_a?(Player)
          else
            entity.debug_color = Color.new(0,1,0)
            other.debug_color = Color.new(0,1,0)
          end
        end
      end
    end

    def update
      lazy_check_collisions
      # @aabb_tree.rebuild
    end
  end
end
