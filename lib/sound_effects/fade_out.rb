# frozen_string_literal: true

class IMICFPS
  class SoundEffect
    class FadeOut < FadeIn
      def ratio
        1.0 - super
      end
    end
  end
end
