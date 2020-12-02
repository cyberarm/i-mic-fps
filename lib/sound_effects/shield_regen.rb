# frozen_string_literal: true
class IMICFPS
  class SoundEffect
    class ShieldRegen < SoundEffect
      def setup
        @sound = SoundManager.sound("base", :shield_regen)
        @player = @options[:player]

        @channel = @sound.play(0.0, 0.0, true)
      end

      def ratio
        @player.health
      end

      def update
        @channel.speed = 0.5 + ratio / 2
        @channel.volume = 1.0 - ratio / 2
      end

      def done?
        ratio >= 1.0
      end
    end
  end
end