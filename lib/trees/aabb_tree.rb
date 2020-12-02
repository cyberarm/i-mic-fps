# frozen_string_literal: true

class IMICFPS
  class AABBTree
    include IMICFPS::AABBTreeDebug

    attr_reader :root, :objects, :branches, :leaves

    def initialize
      @objects = {}
      @root = nil
      @branches = 0
      @leaves   = 0
    end

    def insert(object, bounding_box)
      raise "BoundingBox can't be nil!" unless bounding_box
      raise "Object can't be nil!" unless object
      raise "Object already in tree!" if @objects[object]

      leaf = AABBNode.new(parent: nil, object: object, bounding_box: bounding_box.dup)
      @objects[object] = leaf

      insert_leaf(leaf)
    end

    def insert_leaf(leaf)
      @root = if @root
                @root.insert_subtree(leaf)
              else
                leaf
              end
    end

    def update(object, bounding_box)
      leaf = remove(object)
      leaf.bounding_box = bounding_box
      insert_leaf(leaf)
    end

    # Returns a list of all objects that collided with collider
    def search(collider, return_nodes = false)
      items = []
      if @root
        items = @root.search_subtree(collider)
        items.map!(&:object) unless return_nodes
      end

      items
    end

    def remove(object)
      leaf  = @objects.delete(object)
      @root = @root.remove_subtree(leaf) if leaf

      leaf
    end
  end
end
