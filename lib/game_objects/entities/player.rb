require "etc"

class IMICFPS
  class Player < Entity

    attr_accessor :speed
    attr_reader :name, :bound_model, :first_person_view

    def setup
      bind_model
      @collision = :dynamic
      @physics = true

      @speed = 2.5 # meter's per second
      @running_speed = 5.0 # meter's per second
      @turn_speed = 50.0
      @old_speed = @speed
      @mass = 72 # kg
      @first_person_view = true
      @visible = false
      @drag = 0.6

      @devisor = 500.0
      @name_image = Gosu::Image.from_text("#{Etc.getlogin}", 100, font: "Consolas", align: :center)
      # @name_image.save("temp.png")
      # @name_tex = @name_image.gl_tex_info
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
      _width  = (@name_image.width  / @devisor) / 2
      _height = (@name_image.height / @devisor)
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
      # Do not handle movement if mouse is not captured
      return if @camera && !@camera.mouse_captured

      super
    end

    def relative_speed
      InputMapper.down?(:sprint) ? @running_speed : @speed
    end

    def relative_y_rotation
      @orientation.y * -1
    end

    def forward
      @velocity.z += Math.cos(relative_y_rotation * Math::PI / 180) * relative_speed
      @velocity.x -= Math.sin(relative_y_rotation * Math::PI / 180) * relative_speed
    end

    def backward
      @velocity.z -= Math.cos(relative_y_rotation * Math::PI / 180) * relative_speed
      @velocity.x += Math.sin(relative_y_rotation * Math::PI / 180) * relative_speed
    end

    def strife_left
      @velocity.z += Math.sin(relative_y_rotation * Math::PI / 180) * relative_speed
      @velocity.x += Math.cos(relative_y_rotation * Math::PI / 180) * relative_speed
    end

    def strife_right
      @velocity.z -= Math.sin(relative_y_rotation * Math::PI / 180) * relative_speed
      @velocity.x -= Math.cos(relative_y_rotation * Math::PI / 180) * relative_speed
    end

    def turn_left
      @orientation.y += @turn_speed * delta_time
    end

    def turn_right
      @orientation.y -= @turn_speed * delta_time
    end

    def jump
      if InputMapper.down?(:jump) && window.current_state.collision_manager.on_ground?(self)
        @velocity.y = 1.5
      end
    end

    def toggle_first_person_view
      @first_person_view = !@first_person_view
      @visible = !@first_person_view
    end

    def turn_180
      @orientation.y = @orientation.y + 180
      @orientation.y %= 360
    end
  end
end
