class IMICFPS
  class AABBTree
    def initialize
      @objects = {}
      @root = nil
    end

    def insert(object, bounding_box)
      raise "BoundingBox can't be nil!" unless bounding_box
      raise "Object can't be nil!" unless object
      raise "Object already in tree!" if @objects[object]

      leaf = AABBNode.new(parent: nil, object: object, bounding_box: bounding_box.dup)
      @objects[object] = leaf

      if @root
        @root.insert_subtree(leaf)
      else
        @root = leaf
      end
    end

    def update
      needs_update = []

      @objects.each do |object, node|
        next unless object.is_a?(Entity)
        unless object.normalized_bounding_box == node.bounding_box
          needs_update << object
        end
      end

      needs_update.each do |object|
        remove(object)
        insert(object, object.normalized_bounding_box)
      end
    end

    # Returns a list of all collided objects inside Bounding Box
    def search(bounding_box)
      items = []
      if @root
        items = @root.search_subtree(bounding_box)
      end

      items.map! {|e| e.object}
      return items
    end

    def remove(object)
      leaf = @objects.delete(object)
      @root.remove_subtree(leaf) if leaf
    end
  end
end