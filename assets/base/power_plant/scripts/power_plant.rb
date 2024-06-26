# frozen_string_literal: true

component(:building)

on.create do |event|
  map.insert_entity("base", "purchase_terminal", event.entity.position + Vector.new(-1.5, 1.5, -4.52), Vector.new(0, 20, 0), data: { team: nil })
  map.insert_entity("base", "information_panel", event.entity.position + Vector.new(3, 0, 1), Vector.new(0, -90, 0))
  map.insert_entity("base", "door", event.entity.position + Vector.new(0, 0, 6), Vector.new(0, 0, 0))
  map.insert_entity("base", "door", event.entity.position + Vector.new(0, 0, 6), Vector.new(0, 180, 0))
end
