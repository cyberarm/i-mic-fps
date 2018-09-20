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
      @bounding_box_renderer.draw_bounding_boxes if $debug
      $window.number_of_faces+=@bounding_box_renderer.bounding_boxes[:vertices].size/3 if $debug
      @bounding_box_renderer.bounding_boxes.clear


      ObjectManager.objects.each do |object|
        if object.visible && object.renderable
          @opengl_renderer.draw_object(object)
        end
      end
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