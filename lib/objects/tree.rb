class IMICFPS
  class Tree < GameObject
    def setup
      bind_model(ModelLoader.new(type: :obj, file_path: "objects/tree.obj", game_object: self))
    end

    # def update
    #   super
    #   @y_rotation+=0.005
    # end
  end
end
