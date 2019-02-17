class IMICFPS
  class CollisionManager
    def initialize(game_state:)
      @game_state = game_state
      # @aabb_tree  = AABBTree.new
    end

    def lazy_check_collisions
      # Expensive AABB collision detection
      @game_state.game_objects.each do |object|
        @game_state.game_objects.each do |b|
          next if object == b
          next if object.is_a?(Terrain) || b.is_a?(Terrain)

          if object.intersect(object, b)
            object.debug_color = Color.new(1.0,0.0,0.0)
            b.debug_color = Color.new(1.0,0.0,0.0)

           # @game_state.game_objects.delete(object) unless object.is_a?(Player)
            # puts "#{object} is intersecting #{b}" if object.is_a?(Player)
          else
            object.debug_color = Color.new(0,1,0)
            b.debug_color = Color.new(0,1,0)
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
