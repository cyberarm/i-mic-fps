class IMICFPS
  class OpenGLRenderer
    include CommonMethods

    def draw_object(object)
      handleGlError

      glEnable(GL_NORMALIZE)
      glPushMatrix

      glTranslatef(object.position.x, object.position.y, object.position.z)
      glScalef(object.scale.x, object.scale.y, object.scale.z)
      glRotatef(object.orientation.x, 1.0, 0, 0)
      glRotatef(object.orientation.y, 0, 1.0, 0)
      glRotatef(object.orientation.z, 0, 0, 1.0)

      handleGlError

      if Shader.available?("ddefault")
        Shader.use("default") do |shader|
          glUniform3f(shader.attribute_location("worldPosition"), object.position.x, object.position.y, object.position.z)

          handleGlError
          draw_mesh(object.model)
          # draw_model(object.model)
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

    def draw_model(model)
      glBindVertexArray(model.vertex_array_id)
      glBindBuffer(GL_ARRAY_BUFFER, model.vertices_buffer_id)
      glEnableVertexAttribArray(0)
      glEnableVertexAttribArray(1)
      glEnableVertexAttribArray(2)
      glEnableVertexAttribArray(3)
      glEnableVertexAttribArray(4)

      glDrawArrays(GL_TRIANGLES, 0, model.vertices.count)
      window.number_of_vertices+=model.vertices.size

      glDisableVertexAttribArray(4)
      glDisableVertexAttribArray(3)
      glDisableVertexAttribArray(2)
      glDisableVertexAttribArray(1)
      glDisableVertexAttribArray(0)

      glBindBuffer(GL_ARRAY_BUFFER, 0)
      glBindVertexArray(0)
    end

    def draw_mesh(model)
      model.objects.each_with_index do |o, i|
        glEnable(GL_CULL_FACE) if model.entity.backface_culling
        glEnable(GL_COLOR_MATERIAL)
        glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)
        glShadeModel(GL_FLAT) unless o.faces.first[4]
        glShadeModel(GL_SMOOTH) if o.faces.first[4]
        glEnableClientState(GL_VERTEX_ARRAY)
        glEnableClientState(GL_COLOR_ARRAY)
        glEnableClientState(GL_NORMAL_ARRAY)
        if model.has_texture?
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

        if $debug.get(:wireframe) # This is kinda expensive
          glDisable(GL_LIGHTING)
          glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
          glPolygonOffset(2, 0.5)
          glLineWidth(3)

          glDrawArrays(GL_TRIANGLES, 0, o.flattened_vertices_size/4)
          window.number_of_vertices+=model.vertices.size

          glLineWidth(1)
          glPolygonOffset(0, 0)
          glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
          glEnable(GL_LIGHTING)

          glDrawArrays(GL_TRIANGLES, 0, o.flattened_vertices_size/4)
          window.number_of_vertices+=model.vertices.size
        else
          glDrawArrays(GL_TRIANGLES, 0, o.flattened_vertices_size/4)
          window.number_of_vertices+=model.vertices.size
        end

        # glBindBuffer(GL_ARRAY_BUFFER, 0)

        glDisableClientState(GL_VERTEX_ARRAY)
        glDisableClientState(GL_COLOR_ARRAY)
        glDisableClientState(GL_NORMAL_ARRAY)
        if model.has_texture?
          glDisableClientState(GL_TEXTURE_COORD_ARRAY)
          glDisable(GL_TEXTURE_2D)
        end
        glDisable(GL_CULL_FACE) if model.entity.backface_culling
        glDisable(GL_COLOR_MATERIAL)
      end
    end
  end
end