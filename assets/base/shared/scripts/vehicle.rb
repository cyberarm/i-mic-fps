# frozen_string_literal: true

component(:vehicle) # Generic, Weapon

on.button_down(:interact) do |event|
  CyberarmEngine::Window.instance.console.stdin("#{event.entity.name} handled button_down(:interact)")
  # if event.player.touching?(event.entity)
  #   event.player.enter_vehicle
  # elsif event.player.driving?(event.entity) or event.player.passenger?(event.entity)
  #   event.player.exit_vehicle
  # end
end
