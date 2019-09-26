require "fiddle"
require "yaml"
require "json"
require "abbrev"
require "time"

require "opengl"
require "glu"

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

require_relative "lib/states/game_states/game"
require_relative "lib/states/game_states/loading_state"

require_relative "lib/game_objects/entity"
require_relative "lib/game_objects/model_loader"
require_relative "lib/game_objects/light"

require_relative "lib/game_objects/camera"
require_relative "lib/game_objects/entities/player"
require_relative "lib/game_objects/entities/skydome"
require_relative "lib/game_objects/entities/terrain"

require_relative "lib/wavefront/model"

require_relative "lib/map"
require_relative "lib/manifest"

require_relative "lib/window"

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
