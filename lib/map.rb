class IMICFPS
  class Map
    include EntityManager
    include LightManager

    attr_reader :collision_manager
    attr_reader :gravity
    def initialize(map_loader:, gravity: IMICFPS::GRAVITY)
      @map_loader = map_loader
      @gravity = gravity

      @entities = []
      @lights   = []

      @collision_manager = CollisionManager.new(map: self)
      @renderer = Renderer.new(map: self)
      Publisher.new
    end

    def setup
      add_entity(Terrain.new(map_entity: @map_loader.terrain, manifest: Manifest.new(package: @map_loader.terrain.package, name: @map_loader.terrain.name)))

      add_entity(Skydome.new(map_entity: @map_loader.skydome, manifest: Manifest.new(package: @map_loader.skydome.package, name: @map_loader.skydome.name), backface_culling: false))

      @map_loader.entities.each do |ent|
        add_entity(Entity.new(map_entity: ent, manifest: Manifest.new(package: ent.package, name: ent.name)))
      end

      add_entity(Player.new(spawnpoint: @map_loader.spawnpoints.sample, manifest: Manifest.new(package: "base", name: "biped")))

      # TODO: Load lights from MapLoader
      add_light(Light.new(id: available_light, x: 3, y: -6, z: 6))
      add_light(Light.new(id: available_light, x: 0, y: 100, z: 0, diffuse: Color.new(1.0, 0.5, 0.1)))
    end

    def data
      @map_loader
    end

    def glError?
      e = glGetError()
      if e != GL_NO_ERROR
        $stderr.puts "OpenGL error in: #{gluErrorString(e)} (#{e})\n"
        exit
      end
    end

    def render(camera)
      glError?

      Gosu.gl do
        glError?
        glClearColor(0,0.2,0.5,1) # skyish blue
        glError?
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) # clear the screen and the depth buffer
        glError?

        @lights.each(&:draw)

        camera.draw
        glEnable(GL_DEPTH_TEST)

        @renderer.draw
      end
    end

    def update
      @collision_manager.update

      @entities.each(&:update)
      # @lights.each(&:update)
    end
  end
end