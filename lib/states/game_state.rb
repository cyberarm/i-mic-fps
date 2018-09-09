class IMICFPS
  class GameState
    include CommonMethods

    def initialize
      @delta_time = Gosu.milliseconds
      setup
    end

    def setup
    end

    def draw
    end

    def update
    end

    def button_up(id)
    end
  end
end