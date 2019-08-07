class IMICFPS
  class GameState < CyberarmEngine::GameState
    include CommonMethods
    include EntityManager
    include LightManager

    attr_reader :options
    def initialize(options = {})
      @delta_time = Gosu.milliseconds
      @entities   = []
      @lights     = []

      super
    end
  end
end