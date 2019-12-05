class IMICFPS
  class Renderer
    include CommonMethods

    attr_reader :opengl_renderer, :bounding_box_renderer

    def initialize
      # @bounding_box_renderer = BoundingBoxRenderer.new(map: map)
      @opengl_renderer = OpenGLRenderer.new
    end

    def draw(camera, lights, entities)
      entities.each do |object|
        if object.visible && object.renderable
          # Render bounding boxes before transformation is applied
          # @bounding_box_renderer.create_bounding_box(object, object.model.bounding_box, object.debug_color, object.object_id) if $debug.get(:boundingboxes)

          @opengl_renderer.draw_object(camera, lights, object)
        end
      end

      # @bounding_box_renderer.draw_bounding_boxes if $debug.get(:boundingboxes)
      # window.number_of_vertices+=@bounding_box_renderer.vertex_count if $debug.get(:boundingboxes)
      # @bounding_box_renderer.bounding_boxes.clear
    end

    def finalize # cleanup
    end
  end
end
