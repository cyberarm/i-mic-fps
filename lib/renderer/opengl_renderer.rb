class IMICFPS
  class OpenGLRenderer
    include CommonMethods

    @@immediate_mode_warning = false

    def initialize
      @g_buffer = GBuffer.new
    end

    def canvas_size_changed
      @g_buffer.unbind_framebuffer
      @g_buffer.clean_up

      @g_buffer = GBuffer.new
    end

    def render(camera, lights, entities)
      if window.config.get(:debug_options, :use_shaders) && Shader.available?("default") && Shader.available?("render_screen")
        @g_buffer.bind_for_writing
        gl_error?

        glClearColor(0.0, 0.0, 0.0, 0.0)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        Shader.use("default") do |shader|
          lights.each_with_index do |light, i|
            shader.uniform_float("lights[#{i}.end", -1.0);
            shader.uniform_float("lights[#{i}.type", light.type);
            shader.uniform_vec3("lights[#{i}].position", light.position)
            shader.uniform_vec3("lights[#{i}].ambient", light.ambient)
            shader.uniform_vec3("lights[#{i}].diffuse", light.diffuse)
            shader.uniform_vec3("lights[#{i}].specular", light.specular)
          end
          gl_error?


          shader.uniform_integer("totalLights", lights.size)

          entities.each do |entity|
            next unless entity.visible && entity.renderable

            shader.uniform_transform("projection", camera.projection_matrix)
            shader.uniform_transform("view", camera.view_matrix)
            shader.uniform_transform("model", entity.model_matrix)
            shader.uniform_boolean("hasTexture", entity.model.has_texture?)
            shader.uniform_vec3("cameraPosition", camera.position)

            gl_error?
            draw_model(entity.model, shader)
            entity.draw
          end
        end

        @g_buffer.unbind_framebuffer
        gl_error?


        @g_buffer.bind_for_reading
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0)

        # lighting(lights)
        post_processing
        render_framebuffer

        @g_buffer.unbind_framebuffer
        gl_error?
      else
        puts "Shader 'default' failed to compile, using immediate mode for rendering..." unless @@immediate_mode_warning
        @@immediate_mode_warning = true

        gl_error?
        lights.each(&:draw)
        camera.draw

        glEnable(GL_NORMALIZE)
        entities.each do |entity|
          next unless entity.visible && entity.renderable

          glPushMatrix

          glTranslatef(entity.position.x, entity.position.y, entity.position.z)
          glScalef(entity.scale.x, entity.scale.y, entity.scale.z)
          glRotatef(entity.orientation.x, 1.0, 0, 0)
          glRotatef(entity.orientation.y, 0, 1.0, 0)
          glRotatef(entity.orientation.z, 0, 0, 1.0)

          gl_error?
          draw_mesh(entity.model)
          entity.draw
          glPopMatrix
        end
      end

      gl_error?
    end

    def lighting(lights)
      @g_buffer.set_read_buffer(:position)
      glBlitFramebuffer(0, 0, @g_buffer.width, @g_buffer.height,
                        0, 0, @g_buffer.width / 2, @g_buffer.height / 2,
                        GL_COLOR_BUFFER_BIT, GL_LINEAR)

      @g_buffer.set_read_buffer(:diffuse)
      glBlitFramebuffer(0, 0, @g_buffer.width, @g_buffer.height,
                        0, @g_buffer.height / 2, @g_buffer.width / 2, @g_buffer.height,
                        GL_COLOR_BUFFER_BIT, GL_LINEAR)

      @g_buffer.set_read_buffer(:normal)
      glBlitFramebuffer(0, 0, @g_buffer.width, @g_buffer.height,
                        @g_buffer.width / 2, @g_buffer.height / 2, @g_buffer.width, @g_buffer.height,
                        GL_COLOR_BUFFER_BIT, GL_LINEAR)

      @g_buffer.set_read_buffer(:texcoord)
      glBlitFramebuffer(0, 0, @g_buffer.width, @g_buffer.height,
                        @g_buffer.width / 2, 0, @g_buffer.width, @g_buffer.height / 2,
                        GL_COLOR_BUFFER_BIT, GL_LINEAR)
    end

    def post_processing
    end

    def render_framebuffer
      if Shader.available?("render_screen")
        Shader.use("render_screen") do |shader|
          glBindVertexArray(@g_buffer.screen_vbo)
          glEnableVertexAttribArray(0)
          glEnableVertexAttribArray(1)

          glDisable(GL_DEPTH_TEST)
          glEnable(GL_BLEND)

          glActiveTexture(GL_TEXTURE0)
          glBindTexture(GL_TEXTURE_2D, @g_buffer.texture(:diffuse))

          glDrawArrays(GL_TRIANGLES, 0, @g_buffer.vertices.size)

          glDisableVertexAttribArray(1)
          glDisableVertexAttribArray(0)
          glBindVertexArray(0)
        end
      end
    end

    def draw_model(model, shader)
      glBindVertexArray(model.vertex_array_id)
      glEnableVertexAttribArray(0)
      glEnableVertexAttribArray(1)
      glEnableVertexAttribArray(2)
      if model.has_texture?
        glEnableVertexAttribArray(3)
        glEnableVertexAttribArray(4)
      end

      if window.config.get(:debug_options, :wireframe)
        glLineWidth(2)
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
        Shader.active_shader.uniform_boolean("disableLighting", true)

        glDrawArrays(GL_TRIANGLES, 0, model.faces.count * 3)
        window.number_of_vertices += model.faces.count * 3

        Shader.active_shader.uniform_boolean("disableLighting", false)
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
        glLineWidth(1)
      end

      offset = 0
      model.objects.each do |object|
        if object.has_texture?
          glBindTexture(GL_TEXTURE_2D, object.materials.find { |mat| mat.texture_id }.texture_id)
        end

        glDrawArrays(GL_TRIANGLES, offset, object.faces.count * 3)
        offset += object.faces.count * 3
      end
      window.number_of_vertices += model.faces.count * 3

      if model.has_texture?
        glDisableVertexAttribArray(4)
        glDisableVertexAttribArray(3)

        glBindTexture(GL_TEXTURE_2D, 0)
      end
      glDisableVertexAttribArray(2)
      glDisableVertexAttribArray(1)
      glDisableVertexAttribArray(0)

      glBindBuffer(GL_ARRAY_BUFFER, 0)
      glBindVertexArray(0)
    end

    def draw_mesh(model)
      model.objects.each_with_index do |o, i|
        glEnable(GL_COLOR_MATERIAL)
        glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)
        glShadeModel(GL_FLAT) unless o.faces.first[4]
        glShadeModel(GL_SMOOTH) if o.faces.first[4]
        glEnableClientState(GL_VERTEX_ARRAY)
        glEnableClientState(GL_COLOR_ARRAY)
        glEnableClientState(GL_NORMAL_ARRAY)

        if o.has_texture?
          glEnable(GL_TEXTURE_2D)
          glBindTexture(GL_TEXTURE_2D, o.materials.find { |mat| mat.texture_id }.texture_id)
          glEnableClientState(GL_TEXTURE_COORD_ARRAY)
          glTexCoordPointer(3, GL_FLOAT, 0, o.flattened_uvs)
        end

        glVertexPointer(4, GL_FLOAT, 0, o.flattened_vertices)
        glColorPointer(3, GL_FLOAT, 0, o.flattened_materials)
        glNormalPointer(GL_FLOAT, 0, o.flattened_normals)

        if window.config.get(:debug_options, :wireframe) # This is kinda expensive
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

        if o.has_texture?
          glDisableClientState(GL_TEXTURE_COORD_ARRAY)
          glDisable(GL_TEXTURE_2D)
        end

        glDisable(GL_COLOR_MATERIAL)
      end
    end
  end
end
