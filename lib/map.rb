class IMICFPS
  class Map
    include EntityManager
    include LightManager
    include CommonMethods

    attr_reader :collision_manager
    attr_reader :gravity
    def initialize(map_parser:, gravity: IMICFPS::EARTH_GRAVITY)
      @map_parser = map_parser
      @gravity = gravity

      @entities = []
      @lights   = []

      @collision_manager = CollisionManager.new(map: self)
      Publisher.new
    end

    def setup
      add_entity(Terrain.new(map_entity: @map_parser.terrain, manifest: Manifest.new(package: @map_parser.terrain.package, name: @map_parser.terrain.name)))

      add_entity(Skydome.new(map_entity: @map_parser.skydome, manifest: Manifest.new(package: @map_parser.skydome.package, name: @map_parser.skydome.name), backface_culling: false))

      @map_parser.lights.each do |l|
        add_light(Light.new(id: available_light, position: l.position, diffuse: l.diffuse, ambient: l.ambient, specular: l.specular, intensity: l.intensity))
      end

      @map_parser.entities.each do |ent|
        add_entity(Entity.new(map_entity: ent, manifest: Manifest.new(package: ent.package, name: ent.name)))
      end

      add_entity(Player.new(spawnpoint: @map_parser.spawnpoints.sample, manifest: Manifest.new(package: "base", name: "character")))

      # Default lights if non are defined
      if @map_parser.lights.size == 0
        add_light(Light.new(id: available_light, position: Vector.new(30, 10.0, 30)))
        add_light(Light.new(id: available_light, position: Vector.new(0, 100, 0), diffuse: Color.new(1.0, 0.5, 0.1)))
      end
    end

    def data
      @map_parser
    end

    def render(camera)
      gl_error?

      Gosu.gl do
        gl_error?
        glClearColor(0,0.2,0.5,1) # skyish blue
        gl_error?
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) # clear the screen and the depth buffer
        gl_error?

        window.renderer.draw(camera, @lights, @entities)
      end
    end

    def update
      @collision_manager.update

      @entities.each(&:update)
      # @lights.each(&:update)
    end
  end
end
