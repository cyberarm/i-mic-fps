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
          puts "Updating #{entity.class}"
          @aabb_tree.update(entity, entity.bounding_box.clone)
        end
      end

      check_broadphase

      @physics_manager.update
    end

    def search(collider)
      @aabb_tree.search(collider)
    end

    def remove(entity)
      @aabb_tree.remove(entity)
    end

    def check_broadphase
      # FIXME: Cache collisions to speed things up
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
        _collisions.each do |ent|
          # aabb vs aabb
          next unless entity.bounding_box.intersect?(ent.bounding_box)
          # entity model aabb tree vs ent model aabb tree
          ent_tree_search = ent.model.aabb_tree.search(localize_entity_bounding_box(entity, ent), true)
          next if ent_tree_search.size == 0

          # puts "#{ent.class} -> #{ent_tree_search.size} (#{Gosu.milliseconds})"

          entity.position.y = ent_tree_search.first.object.vertices.first.y if entity.is_a?(Player) && ent.is_a?(Terrain)

          @collisions[entity] = _collisions
        end
      end
    end

    # AABBTree on entities is relative to model origin of 0,0,0
    def localize_entity_bounding_box(entity, target)
      return entity.bounding_box if target.position == 0 && target.orientation == 0

      # "tranform" entity bounding box into target's space
      local =  (target.position) # needs tweaking, works well enough for now
      box = entity.bounding_box.clone
      box.min -= local
      box.max -= local

      return box
    end

    def on_ground?(entity) # TODO: Use some form of caching to speed this up
      on_ground = false
      @collisions.detect do |a, b|
        next unless entity == a || entity == b

        vs = a
        vs = b if a == entity

        broadphase = search(Ray.new(entity.position, Vector.new(0, -1, 0), entity.velocity.y.abs))

        broadphase.detect do |ent|
          ray = Ray.new(entity.position - ent.position, Vector.new(0, -1, 0))
          if ent.model.aabb_tree.search(ray).size > 0
            on_ground = true
            return true
          end
        end

        break if on_ground
      end

      return on_ground
    end
  end
end
