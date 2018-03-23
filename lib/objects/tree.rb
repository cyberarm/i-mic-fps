class IMICFPS
  class Tree < GameObject
    def setup
      bind_model(ModelLoader.new(type: :obj, file_path: "objects/tree.obj", game_object: self))
    end
  end
end
