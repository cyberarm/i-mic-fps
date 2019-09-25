class IMICFPS
  class Skydome < Entity
    def setup
      @collision = :none
    end

    def draw
      glDisable(GL_LIGHTING)
      super
      glEnable(GL_LIGHTING)
    end

    def update
      @orientation.y += 0.01
      @orientation.y %= 360
      super
    end
  end
end
