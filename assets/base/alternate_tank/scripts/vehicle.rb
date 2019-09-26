context Vehicle # Generic, Weapon

on.button_down(:interact) do |event|
  if event.player.touching?(event.entity)
    event.player.enter_vehicle
  elsif event.player.driving?(event.entity) or event.player.passenger?(event.entity)
    event.player.exit_vehicle
  end
end