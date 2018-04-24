require "etc"

class IMICFPS
  class Player < GameObject

    attr_accessor :speed
    attr_reader :name, :bound_model, :first_person_view
    def setup
      bind_model(ModelLoader.new(type: :obj, file_path: "objects/biped.obj", game_object: self))

      @speed = 0.05
      @old_speed = @speed
      @first_person_view = true

      @devisor = 500.0
      @name_image = Gosu::Image.from_text("#{Etc.getlogin}", 100, font: "Consolas", align: :center)
      # @name_image.save("temp.png")
      p @name_image.width/@devisor
      p @name_image.height/@devisor
      @name_tex = @name_image.gl_tex_info
      array_of_pixels = @name_image.to_blob

      tex_names_buf = ' ' * 8
      glGenTextures(1, tex_names_buf)
      @name_texture_id = tex_names_buf.unpack('L2').first

      glBindTexture(GL_TEXTURE_2D, @name_texture_id)
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, @name_image.width, @name_image.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, array_of_pixels)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
      glGenerateMipmap(GL_TEXTURE_2D)
    end

    def draw_nameplate
      _height = (@name_image.height/@devisor)
      _width = (@name_image.width/@devisor)/2
      _x = @x
      _y = normalize_bounding_box(model.bounding_box).max_y+0.05
      glPushMatrix
      glDisable(GL_LIGHTING)
      glEnable(GL_COLOR_MATERIAL)
      glEnable(GL_TEXTURE_2D)
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
      glEnable(GL_BLEND)
      glBindTexture(GL_TEXTURE_2D, @name_texture_id)
      glBegin(GL_TRIANGLES)
        # glColor3f(0.0,0.0,0.0)
        # TOP LEFT
        glTexCoord2f(0, 0)
        glVertex3f(_x-_width,_y+_height,@z)

        # TOP RIGHT
        glTexCoord2f(1, 0)
        glVertex3f(_x+_width, _y+_height,@z)

        # BOTTOM LEFT
        glTexCoord2f(0, 1)
        glVertex3f(_x-_width,_y,@z)

        # BOTTOM LEFT
        glTexCoord2f(0, 1)
        glVertex3f(_x-_width,_y,@z)

        # BOTTOM RIGHT
        glTexCoord2f(1, 1)
        glVertex3f(_x+_width, _y,@z)

        # TOP RIGHT
        glTexCoord2f(1, 0)
        glVertex3f(_x+_width,_y+_height,@z)
      glEnd
      # glDisable(GL_BLEND)
      glDisable(GL_TEXTURE_2D)
      glEnable(GL_LIGHTING)
      glPopMatrix
    end

    def draw
      if !@first_person_view
        draw_nameplate
        super
      end
    end

    def update
      super

      relative_speed = @speed
      if button_down?(Gosu::KbLeftControl)
        relative_speed = (@speed*10.0)*(delta_time/60.0)
      else
        relative_speed = @speed*(delta_time/60.0)
      end

      relative_y_rotation = @y_rotation*-1

      if button_down?(Gosu::KbUp) || button_down?(Gosu::KbW)
        @z+=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
        @x-=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
      end
      if button_down?(Gosu::KbDown) || button_down?(Gosu::KbS)
        @z-=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
        @x+=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
      end
      if button_down?(Gosu::KbA)
        @z+=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
        @x+=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
      end
      if button_down?(Gosu::KbD)
        @z-=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
        @x-=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
      end

      if button_down?(Gosu::KbLeft)
        @y_rotation+=relative_speed*100
      end
      if button_down?(Gosu::KbRight)
        @y_rotation-=relative_speed*100
      end

      @y-=relative_speed if button_down?(Gosu::KbC) || button_down?(Gosu::KbLeftShift) unless @y <= 0
      @y+=relative_speed if button_down?(Gosu::KbSpace)

      @y = 0 if @y < 0
      # distance = 2.0
      # x_offset = distance * Math.cos(@bound_model.y_rotation)
      # z_offset = distance * Math.sin(@bound_model.y_rotation)
    end

    def button_up(id)
      case id
      when Gosu::KbX
        @y_rotation = @y_rotation+180
        @y_rotation %= 360
      when Gosu::KbF
        @first_person_view = !@first_person_view
        puts "First Person? #{@first_person_view}"
      end
    end
  end
end
