class IMICFPS
  class Skydome < GameObject
    def setup
      bind_model(ModelLoader.new(type: :obj, file_path: "objects/skydome.obj", game_object: self))
      p model.class
      # raise "Skydome scale: #{self.scale}" unless self.scale == 1
    end
  end
end
