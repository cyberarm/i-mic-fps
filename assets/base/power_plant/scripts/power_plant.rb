context Building

on.create do |event|
  map.add_entity("base", "purchase_terminal", Vector.new(0, 1.5, 0), Vector.new(0, 90, 0), data: {team: event.entity.team})
  map.add_entity("base", "information_panel", Vector.new(2, 1.5, 0), Vector.new(0, 0, 0))
  map.add_entity("base", "door", Vector.new(2, 0, 6), Vector.new(0, 0, 0))
  map.add_entity("base", "door", Vector.new(2, 0, 6), Vector.new(0, 180, 0))
end