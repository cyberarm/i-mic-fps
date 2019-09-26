origin = self.position

on.entity_moved do |event|
  if origin.distance3d(event.entity.position) <= 3.0
    self.position = origin + Vector.up * 2.4
  else
    self.position = origin
  end
end