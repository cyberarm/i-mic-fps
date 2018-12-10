class IMICFPS
  class Skydome < GameObject
    def setup
      bind_model(ModelLoader.new(type: :obj, file_path: "objects/skydome.obj", game_object: self))
    end

    def draw
      glDisable(GL_LIGHTING)
      super
      glEnable(GL_LIGHTING)
    end

    def update
      @y_rotation+=0.01
      @y_rotation%=360
      super
    end
  end
end
