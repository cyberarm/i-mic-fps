class IMICFPS
  class CollisionManager
    attr_reader :game_state, :collisions
    def initialize(game_state:)
      @game_state = game_state
      @collisions = {}

      @aabb_tree       = AABBTree.new
      @physics_manager = PhysicsManager.new(collision_manager: self)
    end

    def add(entity)
      @aabb_tree.insert(entity, entity.normalized_bounding_box)
    end

    def update
      @aabb_tree.update

      check_broadphase

      @physics_manager.update
    end

    def remove(entity)
      @aabb_tree.remove(entity)
    end

    def check_broadphase
      @collisions.clear
      broadphase = {}

      @game_state.entities.each do |entity|
        search = @aabb_tree.search(entity.normalized_bounding_box)
        if search.size > 0
          search.reject! {|ent| ent == entity}
          broadphase[entity] = search
        end
      end

      broadphase.each do |entity, _collisions|
        _collisions.reject! {|ent| !entity.normalized_bounding_box.intersect(ent.normalized_bounding_box)}
        # TODO: mesh aabb tree vs other mesh aabb tree check
        # TODO: triangle vs other triangle check
        _collisions.each do |ent|
          @collisions[entity] = _collisions
        end
      end
    end
  end
end
