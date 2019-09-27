class IMICFPS
  class GameState < CyberarmEngine::GameState
    include CommonMethods

    attr_reader :options
  end
end