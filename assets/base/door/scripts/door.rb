# frozen_string_literal: true

origin = entity.position

on.entity_moved do |event|
  entity.position = if origin.distance3d(event.entity.position) <= 3.0
                      origin + Vector.up * 2.4
                    else
                      origin
                    end
end
