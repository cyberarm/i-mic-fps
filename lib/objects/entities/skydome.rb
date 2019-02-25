class IMICFPS
  class Skydome < Entity
    def setup
      bind_model("base", "skydome")
      @collision = :none
    end

    def draw
      glDisable(GL_LIGHTING)
      super
      glEnable(GL_LIGHTING)
    end

    def update
      @rotation.y += 0.01
      @rotation.y %= 360
      super
    end
  end
end
