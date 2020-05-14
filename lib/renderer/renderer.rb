class IMICFPS
  class Renderer
    include CommonMethods

    attr_reader :opengl_renderer, :bounding_box_renderer

    def initialize
      @bounding_box_renderer = BoundingBoxRenderer.new
      @opengl_renderer = OpenGLRenderer.new
    end

    def preload_default_shaders
      shaders = ["g_buffer", "lighting"]
      shaders.each do |shader|
        Shader.new(
          name: shader,
          includes_dir: "shaders/include",
          vertex: "shaders/vertex/#{shader}.glsl",
          fragment: "shaders/fragment/#{shader}.glsl"
        )
      end
    end

    def draw(camera, lights, entities)
      glViewport(0, 0, window.width, window.height)
      glEnable(GL_DEPTH_TEST)

      @opengl_renderer.render(camera, lights, entities)
      @bounding_box_renderer.render(entities) if window.config.get(:debug_options, :boundingboxes)
    end

    def canvas_size_changed
      @opengl_renderer.canvas_size_changed
    end

    def finalize # cleanup
    end
  end
end
