component(:building)

on.create do |event|
  map.insert_entity("base", "purchase_terminal", event.entity.position + Vector.new(6, 1.5, 3), Vector.new(0, -90, 0), data: {team: nil})
  map.insert_entity("base", "information_panel", event.entity.position + Vector.new(0.5, 0, 3), Vector.new(0, 90, 0))
  map.insert_entity("base", "door", event.entity.position + Vector.new(3.3, 0, 6), Vector.new(0, 0, 0))
  map.insert_entity("base", "door", event.entity.position + Vector.new(3.3, 0, 6), Vector.new(0, 180, 0))
end