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
      @aabb_tree.insert(entity, entity.bounding_box)
    end

    def update
      @game_state.entities.each do |entity|
        next unless entity.is_a?(Entity)
        next unless node = @aabb_tree.objects[entity]

        unless entity.bounding_box == node.bounding_box
          @aabb_tree.update(entity, entity.bounding_box)
        end
      end

      check_broadphase

      @physics_manager.update

      # binding.irb
      # p @aabb_tree
      collisions.each do |ent, list|
        # puts "#{ent.class} -> [#{list.map{|e| e.class}.join(', ')}]"
      end
    end

    def remove(entity)
      @aabb_tree.remove(entity)
    end

    def check_broadphase
      @collisions.clear
      broadphase = {}

      @game_state.entities.each do |entity|
        next unless entity.collidable?
        next if entity.collision == :static # Only dynamic entities can be resolved

        search = @aabb_tree.search(entity.bounding_box)
        if search.size > 0
          search.reject! {|ent| ent == entity || !ent.collidable?}
          broadphase[entity] = search
        end
      end

      broadphase.each do |entity, _collisions|
        _collisions.reject! {|ent| !entity.bounding_box.intersect?(ent.bounding_box)}
        # TODO: mesh aabb tree vs other mesh aabb tree check
        # TODO: triangle vs other triangle check
        _collisions.each do |ent|
          @collisions[entity] = _collisions
        end
      end
    end
  end
end
