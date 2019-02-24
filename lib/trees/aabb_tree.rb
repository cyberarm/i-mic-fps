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
        @root.insert_subtree(bounding_box.dup, object)
      else
        @root = AABBNode.new(parent: nil, object: object, bounding_box: BoundingBox.new)
      end
    end

    def update
      @objects.each do |object, node|
        unless object.bounding_box == node.bounding_box
          puts "#{object.class} mutated!"
          remove(node)
          add(object)
        end
      end
    end

    # Returns a list of all collided objects inside Bounding Box
    def search(bounding_box)
      items = []
      @root.search_subtree(bounding_box)
    end

    def remove(object)
      @root.remove_subtree(@objects[object])
      @objects[object] = nil
    end

    class AABBNode
      attr_accessor :bounding_box, :parent, :object, :a, :b
      def initialize(parent:, object:, bounding_box:)
        @parent = parent
        @object = object
        @bounding_box = bounding_box

        @a = nil
        @b = nil
      end

      def make_leaf
        @a = nil
        @b = nil
      end

      def make_branch(node_a, node_b)

      end

      def insert_subtree(bounding_box, object)
        # p "#{bounding_box} -> #{object.class}"
      end

      def remove_subtree(node)
      end

      def search_subtree(bounding_box)
      end
    end
  end
end