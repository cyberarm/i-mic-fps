class IMICFPS
  class Tree < GameObject
    def setup
      bind_model(ModelLoader.new(type: :obj, file_path: "objects/tree.obj", game_object: self))
      vert = @terrain.find_nearest_vertex(self, 4.5)
      self.x = vert.x
      self.y = vert.y
      self.z = vert.z
    end

    # def update
    #   super
    #   @y_rotation+=0.005
    # end
  end
end
