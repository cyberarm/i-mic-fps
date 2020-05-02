class IMICFPS
  class MapEditorTool
    class Editor < CyberarmEngine::GuiState
      def setup
        @map = Map.new( map_parser: @options[:map] )
        @camera = Camera.new( position: Vector.new, orientation: Vector.new(0, 90, 0) )
      end

      def draw
        window.renderer.draw(@camera, @map.entities, @map.lights)
      end

      def update
        @camera.position.y -= 1 * window.dt
      end
    end
  end
end
