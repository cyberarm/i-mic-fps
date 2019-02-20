class IMICFPS
  class AABBTree
    def initialize
      @objects = {}
      @root = nil
    end

    def add(bounding_box, object)
      raise "BoundingBox can't be nil!" unless bounding_box
      raise "Object can't be nil!" unless object

      if @root
        @root.insert_subtree(bounding_box, object)
      else
        @root = AABBNode.new(parent: nil, object: object, bounding_box: BoundingBox.new(0,0,0, 0,0,0))
      end
    end

    def update(object)
    end

    # Returns a list of all collided objects inside Bounding Box
    def search(bounding_box)
      items = []
      @root.search_subtree(bounding_box)
    end

    def remove(object)
    end

    class AABBNode
      def initialize(parent:, object:, bounding_box:)
        @parent = parent
        @object = object
        @bounding_box = bounding_box
      end

      def insert_subtree(bounding_box, object)
        p "#{bounding_box} -> #{object.class}"
      end

      def remove_subtree(node)
      end

      def search_subtree(bounding_box)
      end
    end
  end
end