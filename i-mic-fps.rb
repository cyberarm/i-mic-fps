require "fiddle"
require "yaml"
require "abbrev"

require "opengl"
require "glu"

#begin
  require_relative "../cyberarm_engine/lib/cyberarm_engine"
#rescue LoadError
#  require "cyberarm_engine"
#end

Dir.chdir(File.dirname(__FILE__))

case OpenGL.get_platform
when :OPENGL_PLATFORM_WINDOWS
  OpenGL.load_lib("opengl32.dll", "C:/Windows/System32")
  GLU.load_lib("GLU32.dll", "C:/Windows/System32")
when :OPENGL_PLATFORM_MACOSX
  OpenGL.load_lib("libGL.dylib", "/System/Library/Frameworks/OpenGL.framework/Libraries")
  GLU.load_lib("libGLU.dylib", "/System/Library/Frameworks/OpenGL.framework/Libraries")
when :OPENGL_PLATFORM_LINUX
  # Black magic to get GLSL 3.30 support on older Intel hardware
  # if `glxinfo | egrep "OpenGL vendor|OpenGL renderer"`.include?("Intel")
  #   ENV["MESA_GL_VERSION_OVERRIDE"] = "3.3"
  #   ENV["MESA_GLSL_VERSION_OVERRIDE"] = "330"
  # end

  gl_library_path = nil

  if File.exist?("/usr/lib/x86_64-linux-gnu/libGL.so") # Ubuntu (Debian)
    gl_library_path = "/usr/lib/x86_64-linux-gnu"

  elsif File.exist?("/usr/lib/libGL.so") # Manjaro (ARCH)
    gl_library_path = "/usr/lib"

  elsif File.exist?("/usr/lib/arm-linux-gnueabihf/libGL.so") # Raspbian (ARM/Raspberry Pi)
    gl_library_path = "/usr/lib/arm-linux-gnueabihf"
  end

  if gl_library_path
    OpenGL.load_lib("libGL.so", gl_library_path)
    GLU.load_lib("libGLU.so", gl_library_path)
  else
    raise RuntimeError, "Couldn't find GL libraries"
  end
else
  raise RuntimeError, "Unsupported platform."
end

if RUBY_VERSION < "2.5.0"
  puts "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
  puts "|NOTICE| Ruby is #{RUBY_VERSION} not 2.5.0+..............................|Notice|"
  puts "|NOTICE| Monkey Patching Float to add required '.clamp' method.|Notice|"
  puts "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
  puts
  class Float
    def clamp(min, max)
      if self < min
        min
      elsif self > max
        max
      else
        return self
      end
    end
  end
end

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

require_relative "lib/objects/entity"
require_relative "lib/objects/model_loader"
require_relative "lib/objects/light"

require_relative "lib/objects/camera"
require_relative "lib/objects/entities/player"
require_relative "lib/objects/entities/tree"
require_relative "lib/objects/entities/skydome"
require_relative "lib/objects/entities/test_object"
require_relative "lib/objects/entities/terrain"

require_relative "lib/wavefront/model"

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
