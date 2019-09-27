origin = entity.position

on.entity_moved do |event|
  if origin.distance3d(event.entity.position) <= 3.0
    entity.position = origin + Vector.up * 2.4
  else
    entity.position = origin
  end
end