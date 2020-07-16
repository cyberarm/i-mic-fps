component(:building)

on.create do |event|
  map.insert_entity("base", "purchase_terminal", event.entity.position + Vector.new(6, 1.5, 3), Vector.new(0, -90, 0), data: {team: nil})
  map.insert_entity("base", "information_panel", event.entity.position + Vector.new(0.5, 0, 3), Vector.new(0, 90, 0))
  map.insert_entity("base", "door", event.entity.position + Vector.new(3.3, 0, 6), Vector.new(0, 0, 0))
  map.insert_entity("base", "door", event.entity.position + Vector.new(3.3, 0, 6), Vector.new(0, 180, 0))

  # map.insert_particle_emitter(Vector.new(3.0, 15.379, 0.029), Texture.new(path: ["base", "shared", "particles", "smoke", "smoke.png"]))
  # map.insert_particle_emitter(Vector.new(5.0, 15.379, 0.029), Texture.new(path: ["base", "shared", "particles", "smoke", "smoke.png"]))
end