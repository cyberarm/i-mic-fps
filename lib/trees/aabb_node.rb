class IMICFPS
  class AABBTree
    class AABBNode
      attr_accessor :bounding_box, :parent, :object
      attr_reader :a, :b
      def initialize(parent:, object:, bounding_box:)
        @parent = parent
        @object = object
        @bounding_box = bounding_box

        @a = nil
        @b = nil
      end

      def a=(leaf)
        @a = leaf
        @a.parent = self
      end

      def b=(leaf)
        @b = leaf
        @b.parent = self
      end

      def leaf?
        @object
      end

      def insert_subtree(leaf)
        if leaf?
          new_node = AABBNode.new(parent: nil, object: nil, bounding_box: @bounding_box.union(leaf.bounding_box))

          new_node.a = self
          new_node.b = leaf

          return new_node
        else
          cost_a = @a.bounding_box.volume + @b.bounding_box.union(leaf.bounding_box).volume
          cost_b = @b.bounding_box.volume + @a.bounding_box.union(leaf.bounding_box).volume

          if cost_a == cost_b
            cost_a = @a.proximity(leaf)
            cost_b = @b.proximity(leaf)
          end

          if cost_b < cost_a
            self.b = @b.insert_subtree(leaf)
          else
            self.a = @a.insert_subtree(leaf)
          end

          @bounding_box = @bounding_box.union(leaf.bounding_box)

          return self
        end
      end

      def search_subtree(collider, items = [])
        if @bounding_box.intersect?(collider)
          if leaf?
            items << self
          else
            @a.search_subtree(collider, items)
            @b.search_subtree(collider, items)
          end
        end

        return items
      end

      def remove_subtree(leaf)
        if leaf
          return self
        else
          if leaf.parent == self
            other_child = other(leaf)
            other_child.parent = @parent
            return other_child
          else
            leaf.parent.disown_child(leaf)
            return self
          end
        end
      end

      def other(leaf)
        @a == leaf ? @b : @a
      end

      def disown_child(leaf)
        value = other(leaf)
        raise "Can not replace child of a leaf!" if @parent.leaf?
        raise "Node is not a child of parent!" unless leaf.child_of?(@parent)

        if @parent.a == self
          @parent.a = value
        else
          @parent.b = value
        end

        @parent.update_bounding_box
      end

      def child_of?(leaf)
        self == leaf.a || self == leaf.b
      end

      def proximity(leaf)
        (@bounding_box - leaf.bounding_box).sum.abs
      end

      def update_bounding_box
        node = self

        unless node.leaf?
          node.bounding_box = node.a.bounding_box.union(node.b.bounding_box)

          while(node = node.parent)
            node.bounding_box = node.a.bounding_box.union(node.b.bounding_box)
          end
        end
      end
    end
  end
end