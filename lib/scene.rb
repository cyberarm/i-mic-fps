# frozen_string_literal: true

class IMICFPS
  class Scene
    attr_reader :camera, :entities, :lights

    def initialize
      @camera = PerspectiveCamera.new(position: Vector.new, aspect_ratio: $window.aspect_ratio)
      @entities = []
      @lights = []

      setup
    end

    def setup
    end

    def draw
    end

    def update(dt)
    end
  end
end
