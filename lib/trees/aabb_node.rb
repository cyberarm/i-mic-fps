class IMICFPS
  class AABBTree
    class AABBNode
      attr_accessor :bounding_box, :parent, :object, :a, :b
      def initialize(parent:, object:, bounding_box:)
        @parent = parent
        @object = object
        @bounding_box = bounding_box

        @a = nil
        @b = nil
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
          cost_a = @b.bounding_box.volume + @a.bounding_box.union(leaf.bounding_box).volume
          cost_a = @a.bounding_box.volume + @b.bounding_box.union(leaf.bounding_box).volume

          if cost_a < cost_b
            self.a = @a.insert_subtree(leaf)
          elsif cost_b < cost_a
            self.b = @b.insert_subtree(leaf)
          else
            raise "FIXME"
          end

          @bounding_box = @bounding_box.union(leaf.bounding_box)

          return self
        end
      end

      def search_subtree(bounding_box, items = [])
        if @bounding_box.intersect(bounding_box)
          if leaf?
            items << self
          else
            @a.search_subtree(bounding_box, items)
            @b.search_subtree(bounding_box, items)
          end
        end

        return items
      end

      def remove_subtree(leaf)
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