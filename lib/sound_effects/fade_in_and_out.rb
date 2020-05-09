class IMICFPS
  class SoundEffect
    class FadeInAndOut < FadeIn
      def setup
        @hang_time = @options[:hang_time] ? @options[:hang_time] : 0.0

        super
      end

      # TODO: Handle hang time
      def ratio
        r = super

        if r < 0.5
          r * 2
        else
          2.0 - (r * 2)
        end
      end
    end
  end
end