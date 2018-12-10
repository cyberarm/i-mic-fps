class IMICFPS
  class Renderer
    include OpenGL
    include GLU

    attr_reader :opengl_renderer, :bounding_box_renderer

    def initialize
      @bounding_box_renderer = BoundingBoxRenderer.new
      @opengl_renderer = OpenGLRenderer.new
    end

    def draw
      ObjectManager.objects.each do |object|
        if object.visible && object.renderable
          # Render bounding boxes before transformation is applied
          @bounding_box_renderer.create_bounding_box(object, object.model.bounding_box, object.debug_color, object.object_id) if $debug

          @opengl_renderer.draw_object(object)
        end
      end

      @bounding_box_renderer.draw_bounding_boxes if $debug
      $window.number_of_faces+=$window.number_of_faces if $debug
      $window.number_of_faces+=@bounding_box_renderer.vertex_count/3 if $debug
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