class IMICFPS
  class OpenGLRenderer
    include OpenGL
    include GLU

    def initialize
    end

    def handleGlError
      e = glGetError()
      if e != GL_NO_ERROR
        $stderr.puts "OpenGL error in: #{gluErrorString(e)} (#{e})\n"
        exit
      end
    end

    def draw_object(object)
      handleGlError

      glEnable(GL_NORMALIZE)
      glPushMatrix

      glTranslatef(object.x, object.y, object.z)
      glRotatef(object.x_rotation,1.0, 0, 0)
      glRotatef(object.y_rotation,0, 1.0, 0)
      glRotatef(object.z_rotation,0, 0, 1.0)

      handleGlError

      if ShaderManager.shader("lighting")
        ShaderManager.shader("lighting").use do |shader|
          glUniform3f(shader.variable("SunLight"), 1.0, 1.0, 1.0)

          handleGlError
          draw_mesh(object.model)
          object.draw
        end
      else
        handleGlError
        draw_mesh(object.model)
        object.draw
      end
      handleGlError

      glPopMatrix
      handleGlError
    end

    def draw_mesh(model)
      model.objects.each_with_index do |o, i|
        glEnable(GL_CULL_FACE) if model.game_object.backface_culling
        glEnable(GL_COLOR_MATERIAL)
        glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)
        glShadeModel(GL_FLAT) unless o.faces.first[4]
        glShadeModel(GL_SMOOTH) if o.faces.first[4]
        glEnableClientState(GL_VERTEX_ARRAY)
        glEnableClientState(GL_COLOR_ARRAY)
        glEnableClientState(GL_NORMAL_ARRAY)
        if model.model_has_texture
          glEnable(GL_TEXTURE_2D)
          glBindTexture(GL_TEXTURE_2D, model.materials[model.textured_material].texture_id)
          glEnableClientState(GL_TEXTURE_COORD_ARRAY)
          glTexCoordPointer(3, GL_FLOAT, 0, o.flattened_textures)
        end
        glVertexPointer(4, GL_FLOAT, 0, o.flattened_vertices)
        glColorPointer(3, GL_FLOAT, 0, o.flattened_materials)
        glNormalPointer(GL_FLOAT, 0, o.flattened_normals)

        # glBindBuffer(GL_ARRAY_BUFFER, model.vertices_buffer)
        # glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 0, 0)

        if $debug # This is kinda expensive
          glDisable(GL_LIGHTING)
          glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
          glPolygonOffset(2, 0.5)
          glLineWidth(3)

          glDrawArrays(GL_TRIANGLES, 0, o.flattened_vertices_size/4)

          glLineWidth(1)
          glPolygonOffset(0, 0)
          glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
          glEnable(GL_LIGHTING)

          glDrawArrays(GL_TRIANGLES, 0, o.flattened_vertices_size/4)
        else
          glDrawArrays(GL_TRIANGLES, 0, o.flattened_vertices_size/4)
        end

        # glBindBuffer(GL_ARRAY_BUFFER, 0)

        glDisableClientState(GL_VERTEX_ARRAY)
        glDisableClientState(GL_COLOR_ARRAY)
        glDisableClientState(GL_NORMAL_ARRAY)
        if model.model_has_texture
          glDisableClientState(GL_TEXTURE_COORD_ARRAY)
          # glBindTexture(GL_TEXTURE_2D, 0)
          glDisable(GL_TEXTURE_2D)
        end
        glDisable(GL_CULL_FACE) if model.game_object.backface_culling
        glDisable(GL_COLOR_MATERIAL)
      end

      $window.number_of_faces+=model.faces.size
    end
  end
end