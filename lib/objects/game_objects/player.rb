require "etc"

class IMICFPS
  class Player < GameObject

    attr_accessor :speed
    attr_reader :name, :bound_model, :first_person_view

    def setup
      bind_model("base", "biped")
      InputMapper.set(:character, :forward,      [Gosu::KbUp, Gosu::KbW])
      InputMapper.set(:character, :backward,     [Gosu::KbDown, Gosu::KbS])
      InputMapper.set(:character, :strife_left,  Gosu::KbA)
      InputMapper.set(:character, :strife_right, Gosu::KbD)
      InputMapper.set(:character, :turn_left,    Gosu::KbLeft)
      InputMapper.set(:character, :turn_right,   Gosu::KbRight)
      InputMapper.set(:character, :jump,         Gosu::KbSpace)
      InputMapper.set(:character, :sprint,       [Gosu::KbLeftControl])

      InputMapper.set(:character, :turn_180,                 Gosu::KbX)
      InputMapper.set(:character, :toggle_first_person_view, Gosu::KbF)

      @speed = 2.5 # meter's per second
      @running_speed = 6.8 # meter's per second
      @old_speed = @speed
      @mass = 72 # kg
      @y_velocity = 0
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
      @floor = @terrain.height_at(self, 4.5)

      relative_speed = @speed
      if InputMapper.down?(:character, :sprint)
        relative_speed = (@running_speed)*(delta_time)
      else
        relative_speed = @speed*(delta_time)
      end

      relative_y_rotation = @y_rotation*-1

      if InputMapper.down?(:character, :forward)
        @z+=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
        @x-=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
      end
      if InputMapper.down?(:character, :backward)
        @z-=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
        @x+=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
      end
      if InputMapper.down?(:character, :strife_left)
        @z+=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
        @x+=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
      end
      if InputMapper.down?(:character, :strife_right)
        @z-=Math.sin(relative_y_rotation * Math::PI / 180)*relative_speed
        @x-=Math.cos(relative_y_rotation * Math::PI / 180)*relative_speed
      end

      if InputMapper.down?(:character, :turn_left)
        @y_rotation+=(relative_speed*1000)*delta_time
      end
      if InputMapper.down?(:character, :turn_right)
        @y_rotation-=(relative_speed*1000)*delta_time
      end

      if @_time_in_air
        air_time = ((Gosu.milliseconds-@_time_in_air)/1000.0)
        @y_velocity-=(IMICFPS::GRAVITY*air_time)*delta_time
      end

      if InputMapper.down?(:character, :jump) && !@jumping
        @jumping = true
        @_time_in_air = Gosu.milliseconds
      elsif !@jumping && @y > @floor
        @falling = true
        @_time_in_air ||= Gosu.milliseconds # FIXME
      else
        if @jumping
          if @y <= @floor
            @falling = false; @jumping = false; @y_velocity = 0
          end
        end
      end
      if @jumping && !@falling
        if InputMapper.down?(:character, :jump)
          @y_velocity = 1.5
          @falling = true
        end
      end

      @y+=@y_velocity*delta_time

      @y = @floor if @y < @floor
      # distance = 2.0
      # x_offset = distance * Math.cos(@bound_model.y_rotation)
      # z_offset = distance * Math.sin(@bound_model.y_rotation)

      super
    end

    def button_up(id)
      if InputMapper.is?(:character, :turn_180, id)
        @y_rotation = @y_rotation+180
        @y_rotation %= 360

      elsif InputMapper.is?(:character, :toggle_first_person_view, id)
        @first_person_view = !@first_person_view
        puts "First Person? #{@first_person_view}"
      end
    end
  end
end
