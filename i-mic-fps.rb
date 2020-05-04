require "fiddle"
require "yaml"
require "json"
require "abbrev"
require "time"

require "opengl"
require "glu"
require "nokogiri"

begin
  require_relative "../cyberarm_engine/lib/cyberarm_engine"
rescue LoadError => e
  pp e
 require "cyberarm_engine"
end

Dir.chdir(File.dirname(__FILE__))

require_relative "lib/ext/numeric"
require_relative "lib/ext/load_opengl"

include CyberarmEngine
include OpenGL
include GLU

require_relative "lib/version"
require_relative "lib/constants"
require_relative "lib/common_methods"

require_relative "lib/trees/aabb_tree_debug"
require_relative "lib/trees/aabb_tree"
require_relative "lib/trees/aabb_node"

require_relative "lib/managers/input_mapper"
require_relative "lib/managers/entity_manager"
require_relative "lib/managers/light_manager"
require_relative "lib/managers/network_manager"
require_relative "lib/managers/collision_manager"
require_relative "lib/managers/physics_manager"

require_relative "lib/renderer/renderer"
require_relative "lib/renderer/g_buffer"
require_relative "lib/renderer/opengl_renderer"
require_relative "lib/renderer/bounding_box_renderer"

require_relative "lib/states/game_state"
require_relative "lib/ui/menu"

require_relative "lib/ui/command"
require_relative "lib/ui/subcommand"
Dir.glob("#{IMICFPS::GAME_ROOT_PATH}/lib/ui/commands/*.rb").each do |cmd|
  require_relative cmd
end
require_relative "lib/ui/console"
require_relative "lib/ui/menus/main_menu"
require_relative "lib/ui/menus/settings_menu"
require_relative "lib/ui/menus/extras_menu"
require_relative "lib/ui/menus/level_select_menu"
require_relative "lib/ui/menus/game_pause_menu"

require_relative "lib/states/game_states/boot"
require_relative "lib/states/game_states/close"
require_relative "lib/states/game_states/game"
require_relative "lib/states/game_states/loading_state"

require_relative "lib/subscription"
require_relative "lib/publisher"
require_relative "lib/event"
require_relative "lib/event_handler"
require_relative "lib/event_handlers/input"
require_relative "lib/event_handlers/entity_moved"
require_relative "lib/event_handlers/entity_lifecycle"

require_relative "lib/scripting"
require_relative "lib/scripting/sandbox"
require_relative "lib/scripting/whitelist"

require_relative "lib/component"
require_relative "lib/components/building"

require_relative "lib/game_objects/entity"
require_relative "lib/game_objects/light"
require_relative "lib/game_objects/particle_emitter"

require_relative "lib/game_objects/camera"
require_relative "lib/game_objects/entities/player"
require_relative "lib/game_objects/entities/skydome"
require_relative "lib/game_objects/entities/terrain"

require_relative "lib/texture"
require_relative "lib/model"
require_relative "lib/model_cache"
require_relative "lib/model/parser"
require_relative "lib/model/model_object"
require_relative "lib/model/material"

require_relative "lib/model/parsers/wavefront_parser"
require_relative "lib/model/parsers/collada_parser"

require_relative "lib/map_parser"
require_relative "lib/manifest"
require_relative "lib/map"

require_relative "lib/scene"
require_relative "lib/scenes/turn_table"

require_relative "lib/crosshair"
require_relative "lib/demo"

require_relative "lib/networking/director"
require_relative "lib/networking/packet_handler"
require_relative "lib/networking/client"
require_relative "lib/networking/server"
require_relative "lib/networking/connection"

require_relative "lib/networking/backends/memory_server"
require_relative "lib/networking/backends/memory_connection"

require_relative "lib/overlay"
require_relative "lib/window"

require_relative "lib/tools/asset_viewer"
require_relative "lib/tools/map_editor"

if ARGV.join.include?("--profile")
  begin
    require "ruby-prof"
    RubyProf.start
      IMICFPS::Window.new.show
    result  = RubyProf.stop
    printer = RubyProf::MultiPrinter.new(result)
    printer.print(path: ".", profile: "profile", min_percent: 2)
  rescue LoadError
    puts "ruby-prof not installed!"
  end
else
  IMICFPS::Window.new.show
end
