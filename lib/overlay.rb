class IMICFPS
  class Overlay
    include CommonMethods

    Slot = Struct.new(:value, :width)

    def initialize
      @text = CyberarmEngine::Text.new("", x: 3, y: 3, shadow_color: Gosu::Color::BLACK)
      @slots = []
      @space_width = @text.textobject.text_width(" ")
    end

    def draw
      return if @text.text.empty?
      width = @text.width + 8

      Gosu.draw_rect(0, 0, width, (@text.height + 4), Gosu::Color.rgba(0, 0, 0, 100))
      Gosu.draw_rect(2, 2, width - 4, (@text.height + 4) - 4, Gosu::Color.rgba(100, 100, 100, 100))

      @text.draw
    end

    def update
      rebuild_slots
    end

    def rebuild_slots
      @slots.clear

      if window.config.get(:options, :fps)
        create_slot "FPS: #{Gosu.fps}"
        create_slot "Frame time: #{Gosu.milliseconds - window.delta_time}ms" if window.config.get(:debug_options, :stats)
      end

      if window.config.get(:debug_options, :stats)
        create_slot "Vertices: #{formatted_number(window.number_of_vertices)}"
        create_slot "Face: #{formatted_number(window.number_of_vertices / 3)}"
      end

      if window.config.get(:debug_options, :boundingboxes)
        create_slot "Boundingboxes: #{window.config.get(:debug_options, :boundingboxes) ? 'On' : 'Off'}"
      end

      if window.config.get(:debug_options, :wireframe)
        create_slot "Wireframes: #{window.config.get(:debug_options, :wireframe) ? 'On' : 'Off'}"
      end

      @text.text = ""
      @slots.each_with_index do |slot, i|
        @text.text += "#{slot.value} <c=ff000000>•</c> " unless i == @slots.size - 1
        @text.text += "#{slot.value}" if i == @slots.size - 1
      end
    end

    def create_slot(string)
      @slots << Slot.new(string, @text.textobject.text_width(string))
    end
  end
end