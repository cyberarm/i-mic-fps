class IMICFPS
  class Renderer
    include CommonMethods
    include OpenGL
    include GLU

    attr_reader :opengl_renderer, :bounding_box_renderer

    def initialize(game_state:)
      @game_state = game_state

      @bounding_box_renderer = BoundingBoxRenderer.new(game_state: game_state)
      @opengl_renderer = OpenGLRenderer.new
    end

    def draw
      @game_state.entities.each do |object|
        if object.visible && object.renderable
          # Render bounding boxes before transformation is applied
          @bounding_box_renderer.create_bounding_box(object, object.model.bounding_box, object.debug_color, object.object_id) if $debug

          @opengl_renderer.draw_object(object)
        end
      end

      @bounding_box_renderer.draw_bounding_boxes if $debug
      window.number_of_vertices+=@bounding_box_renderer.vertex_count if $debug
      # @bounding_box_renderer.bounding_boxes.clear
    end

    def handleGlError
      e = glGetError()
      if e != GL_NO_ERROR
        $stderr.puts "OpenGL error in: #{gluErrorString(e)} (#{e})\n"
        exit
      end
    end

    def finalize # cleanup
    end
  end
end
