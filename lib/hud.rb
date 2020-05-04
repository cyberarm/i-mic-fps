class IMICFPS
  class HUD
    def initialize(player)
      @ammo = AmmoWidget.new({ player: player })
      @radar = RadarWidget.new({ player: player })
      @health = HealthWidget.new({ player: player })

      @hud_elements = [
        @ammo,
        @radar,
        @health,
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