# frozen_string_literal: true

class IMICFPS
  class SoundEffect
    class FadeIn < SoundEffect
      def setup
        @start_time = Gosu.milliseconds
        @duration = @options[:duration] # in milliseconds
        @initial_volume = @options[:volume] || 0.0
        @sound = @options[:sound]

        raise "duration not specified!" unless @duration

        @channel = @sound.play(calculate_volume)
      end

      def ratio
        (Gosu.milliseconds - @start_time.to_f) / @duration
      end

      def calculate_volume
        volume = (SoundManager.sfx_volume - @initial_volume) * ratio
      end

      def update
        @channel.volume = calculate_volume
      end

      def done?
        (Gosu.milliseconds - @start_time.to_f) / @duration >= 1.0
      end
    end
  end
end
