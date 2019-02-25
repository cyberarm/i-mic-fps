require "etc"

class IMICFPS
  class Player < Entity

    attr_accessor :speed
    attr_reader :name, :bound_model, :first_person_view

    def setup
      bind_model("base", "biped")
      @collision = :dynamic

      @speed = 2.5 # meter's per second
      @running_speed = 6.8 # meter's per second
      @old_speed = @speed
      @mass = 72 # kg
      @floor = 0
      @first_person_view = true

      @devisor = 500.0
      @name_image = Gosu::Image.from_text("#{Etc.getlogin}", 100, font: "Consolas", align: :center)
      # @name_image.save("temp.png")
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
      _y = 2#normalize_bounding_box(model.bounding_box).max_y+0.05
      glPushMatrix
      glRotatef(180, 0, 1, 0)
      glDisable(GL_LIGHTING)
      glEnable(GL_COLOR_MATERIAL)
      glEnable(GL_TEXTURE_2D)
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
      glEnable(GL_BLEND)
      glBindTexture(GL_TEXTURE_2D, @name_texture_id)
      glBegin(GL_TRIANGLES)
        glColor3f(1.0,1.0,1.0)
        # TOP LEFT
        glTexCoord2f(0, 0)
        glVertex3f(0-_width,_y+_height,0)

        # TOP RIGHT
        glTexCoord2f(1, 0)
        glVertex3f(0+_width, _y+_height,0)

        # BOTTOM LEFT
        glTexCoord2f(0, 1)
        glVertex3f(0-_width,_y,0)

        # BOTTOM LEFT
        glTexCoord2f(0, 1)
        glVertex3f(0-_width,_y,0)

        # BOTTOM RIGHT
        glTexCoord2f(1, 1)
        glVertex3f(0+_width, _y,0)

        # TOP RIGHT
        glTexCoord2f(1, 0)
        glVertex3f(0+_width,_y+_height,0)
      glEnd
      # glDisable(GL_BLEND)
      glDisable(GL_TEXTURE_2D)
      glEnable(GL_LIGHTING)
      glPopMatrix
    end

    def draw
      if !@first_person_view
        super
        draw_nameplate
      end
    end

    def update
      relative_speed = @speed
      if InputMapper.down?(:sprint)
        relative_speed = (@running_speed)*(delta_time)
      else
        relative_speed = @speed*(delta_time)
      end

      relative_y_rotation = @rotation.y*-1

      if InputMapper.down?(:forward)
        @position.z+=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
        @position.x-=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
      end
      if InputMapper.down?(:backward)
        @position.z-=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
        @position.x+=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
      end
      if InputMapper.down?(:strife_left)
        @position.z+=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
        @position.x+=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
      end
      if InputMapper.down?(:strife_right)
        @position.z-=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
        @position.x-=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
      end

      if InputMapper.down?(:turn_left)
        @rotation.y+=(relative_speed*1000)*delta_time
      end
      if InputMapper.down?(:turn_right)
        @rotation.y-=(relative_speed*1000)*delta_time
      end

      if @_time_in_air
        air_time = ((Gosu.milliseconds-@_time_in_air)/1000.0)
        @velocity.y-=(IMICFPS::GRAVITY*air_time)*delta_time
      end

      if InputMapper.down?(:jump) && !@jumping
        @jumping = true
        @_time_in_air = Gosu.milliseconds
      elsif !@jumping && @position.y > @floor
        @falling = true
        @_time_in_air ||= Gosu.milliseconds # FIXME
      else
        if @jumping
          if @position.y <= @floor
            @falling = false; @jumping = false; @velocity.y = 0; @position.y = @floor
          end
        end
      end
      if @jumping && !@falling
        if InputMapper.down?(:jump)
          @velocity.y = 1.5
          @falling = true
        end
      end

      @position.y+=@velocity.y*delta_time if @position.y >= @floor # TEMP fix to prevent falling forever, collision/physics managers should fix this in time.

      super
    end

    def button_up(id)
      if InputMapper.is?(:toggle_first_person_view, id)
        @first_person_view = !@first_person_view
        @visible = !@first_person_view
        puts "First Person? #{@first_person_view}"
      elsif InputMapper.is?(:turn_180, id)
        @rotation.y = @rotation.y+180
        @rotation.y %= 360
      end
    end
  end
end
