class IMICFPS
  class TestObject < GameObject
    def setup
      bind_model(ModelLoader.new(type: :obj, file_path: "objects/sponza.obj", game_object: self))
    end
  end
end
