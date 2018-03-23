class IMICFPS
  class Player < GameObject

    attr_accessor :speed
    attr_reader :name, :bound_model
    def setup
      bind_model(ModelLoader.new(type: :obj, file_path: "objects/biped.obj", game_object: self))

      @speed = 0.05
      @old_speed = @speed
    end

    def update
      super

      relative_speed = @speed
      if button_down?(Gosu::KbLeftControl)
        relative_speed = (@speed*10.0)*(delta_time/60.0)
      else
        relative_speed = @speed*(delta_time/60.0)
      end

      if button_down?(Gosu::KbUp) || button_down?(Gosu::KbW)
        @z-=Math.cos(@y_rotation * Math::PI / 180)*relative_speed
        @x+=Math.sin(@y_rotation * Math::PI / 180)*relative_speed
      end
      if button_down?(Gosu::KbDown) || button_down?(Gosu::KbS)
        @z+=Math.cos(@y_rotation * Math::PI / 180)*relative_speed
        @x-=Math.sin(@y_rotation * Math::PI / 180)*relative_speed
      end
      if button_down?(Gosu::KbA)
        @z-=Math.sin(@y_rotation * Math::PI / 180)*relative_speed
        @x-=Math.cos(@y_rotation * Math::PI / 180)*relative_speed
      end
      if button_down?(Gosu::KbD)
        @z+=Math.sin(@y_rotation * Math::PI / 180)*relative_speed
        @x+=Math.cos(@y_rotation * Math::PI / 180)*relative_speed
      end

      if button_down?(Gosu::KbLeft)
        @y_rotation-=relative_speed*100
      end
      if button_down?(Gosu::KbRight)
        @y_rotation+=relative_speed*100
      end

      @y-=relative_speed if button_down?(Gosu::KbC) || button_down?(Gosu::KbLeftShift) unless @y <= 0
      @y+=relative_speed if button_down?(Gosu::KbSpace)

      @y = 0 if @y < 0
      # distance = 2.0
      # x_offset = distance * Math.cos(@bound_model.y_rotation)
      # z_offset = distance * Math.sin(@bound_model.y_rotation)
    end
  end
end
