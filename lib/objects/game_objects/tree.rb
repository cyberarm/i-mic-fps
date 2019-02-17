class IMICFPS
  class Tree < GameObject
    def setup
      bind_model("base", "tree")
      vert = @terrain.find_nearest_vertex(self, 4.5)
      if vert
        self.x = vert.x
        self.y = vert.y
        self.z = vert.z
      end

      # @y_rotation += rand(1..100)
    end

    # def update
    #   super
    #   @y_rotation+=0.005
    # end
  end
end
