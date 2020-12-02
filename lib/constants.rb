# frozen_string_literal: true
class IMICFPS
  GAME_ROOT_PATH = File.expand_path("..", File.dirname(__FILE__))

  SANS_FONT      = "#{GAME_ROOT_PATH}/static/fonts/Cantarell/Cantarell-Regular.otf"
  BOLD_SANS_FONT = "#{GAME_ROOT_PATH}/static/fonts/Cantarell/Cantarell-Bold.otf"
  MONOSPACE_FONT = "#{GAME_ROOT_PATH}/static/fonts/Oxygen_Mono/OxygenMono-Regular.ttf"

  # Objects exported from blender using the default or meter object scale will be close to 1 GL unit
  MODEL_METER_SCALE = 1.0

  # Earth
  EARTH_GRAVITY = 9.8 # m/s
  # Moon
  MOON_GRAVITY = 1.625 # m/s
end
