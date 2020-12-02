# frozen_string_literal: true

class IMICFPS
  class TurnTableScene < Scene
    def setup
      camera.field_of_view = 45
      lights << Light.new(
        id: OpenGL::GL_LIGHT1,
        type: Light::DIRECTIONAL,
        direction: Vector.down,
        position: Vector.new(0, 10, 5),
        diffuse: Color.new(1.0, 1.0, 1.0),
        specular: Color.new(0, 0, 0)
      )

      options = {
        # entity: scale
        "character": 0.25,
        "information_panel": 0.25,
        "purchase_terminal": 0.35,
        "door": 0.2,
        "ttank": 0.13,
        "alternate_tank": 0.065,
        "tree": 0.08,
        "evergreen_tree": 0.08,
        "power_plant": 0.025,
        "war_factory": 0.03,
        "randomish_terrain": 0.004,
        "river_terrain": 0.004
      }
      choice = options.keys.sample

      @entity = Entity.new(manifest: Manifest.new(package: "base", name: choice), run_scripts: false)
      @entity.scale = Vector.new(1, 1, 1) * options[choice]
      @entity.position.x = 0.75
      @entity.position.y = -0.5
      @entity.position.z = -1.5
      @entity.bind_model

      entities << @entity

      @max_tilt = 5.0
    end

    def update(dt)
      @entity.orientation.y += 10 * dt
    end
  end
end
