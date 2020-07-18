class IMICFPS
  class HUD
    def initialize(player)
      @ammo = AmmoWidget.new({ player: player })
      @radar = RadarWidget.new({ player: player })
      @health = HealthWidget.new({ player: player })
      @chat_history = ChatHistoryWidget.new({ player: player })
      @score_board = ScoreBoardWidget.new({ player: player })
      @squad = SquadWidget.new( { player: player } )
      @crosshair = CrosshairWidget.new( { player: player } )

      @hud_elements = [
        @ammo,
        @radar,
        @health,
        @chat_history,
        @score_board,
        @squad,
        
        @crosshair,
      ]
    end

    def draw
      @hud_elements.each(&:draw)
    end

    def update
      @hud_elements.each(&:update)
    end
  end
end
