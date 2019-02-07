class IMICFPS
  class GameState
    include CommonMethods
    include ObjectManager
    include LightManager

    attr_reader :options
    def initialize(options = {})
      @options = options
      @delta_time = Gosu.milliseconds
      @game_objects = []
      @lights       = []

      setup
    end

    def push_game_state(klass_or_instance)
      window.push_game_state(klass_or_instance)
    end

    def setup
    end

    def draw
    end

    def update
    end

    def button_down(id)
    end

    def button_up(id)
    end
  end
end