class IMICFPS
  class Scene
    attr_reader :camera, :entities, :lights

    def initialize
      @camera = Camera.new(position: Vector.new)
      @entities = []
      @lights = []

      setup
    end

    def setup
    end

    def draw
    end

    def update(dt)
    end
  end
end