class IMICFPS
  class GameState
    include CommonMethods
    attr_reader :options
    def initialize(options = {})
      @options = options
      @delta_time = Gosu.milliseconds
      setup
    end

    def push_game_state(klass_or_instance)
      $window.push_game_state(klass_or_instance)
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