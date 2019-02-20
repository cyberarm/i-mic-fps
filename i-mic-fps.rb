require "fiddle"
require "yaml"

require "opengl"
require "glu"
require "gosu"

Dir.chdir(File.dirname(__FILE__))

case OpenGL.get_platform
when :OPENGL_PLATFORM_WINDOWS
  OpenGL.load_lib("opengl32.dll", "C:/Windows/System32")
  GLU.load_lib("GLU32.dll", "C:/Windows/System32")
when :OPENGL_PLATFORM_MACOSX
  OpenGL.load_lib("libGL.dylib", "/System/Library/Frameworks/OpenGL.framework/Libraries")
  GLU.load_lib("libGLU.dylib", "/System/Library/Frameworks/OpenGL.framework/Libraries")
when :OPENGL_PLATFORM_LINUX
  gl_library_path = nil

  if File.exists?("/usr/lib/x86_64-linux-gnu/libGL.so") # Ubuntu (Debian)
    gl_library_path = "/usr/lib/x86_64-linux-gnu"

  elsif File.exists?("/usr/lib/libGL.so") # Manjaro (ARCH)
    gl_library_path = "/usr/lib"

  elsif File.exists?("/usr/lib/arm-linux-gnueabihf/libGL.so") # Raspbian (ARM/Raspberry Pi)
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

BoundingBox = Struct.new(:min_x, :min_y, :min_z, :max_x, :max_y, :max_z)

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

$debug = ARGV.join.include?("--debug") ? true : false

require_relative "lib/common_methods"

require_relative "lib/math/vertex"
require_relative "lib/trees/aabb_tree"

require_relative "lib/managers/input_mapper"
require_relative "lib/managers/shader_manager"
require_relative "lib/managers/entity_manager"
require_relative "lib/managers/light_manager"
require_relative "lib/managers/network_manager"
require_relative "lib/managers/collision_manager"

require_relative "lib/renderer/renderer"
require_relative "lib/renderer/shader"
require_relative "lib/renderer/opengl_renderer"
require_relative "lib/renderer/bounding_box_renderer"

require_relative "lib/states/game_state"
require_relative "lib/states/menu"
require_relative "lib/states/game_states/game"
require_relative "lib/states/game_states/loading_state"
require_relative "lib/states/menus/main_menu"

require_relative "lib/objects/text"
require_relative "lib/objects/multi_line_text"
require_relative "lib/objects/entity"
require_relative "lib/objects/model_loader"
require_relative "lib/objects/light"

require_relative "lib/objects/entities/camera"
require_relative "lib/objects/entities/player"
require_relative "lib/objects/entities/tree"
require_relative "lib/objects/entities/skydome"
require_relative "lib/objects/entities/test_object"
require_relative "lib/objects/entities/terrain"

require_relative "lib/wavefront/model"

require_relative "lib/window"

MODEL_METER_SCALE = 1.0 # Objects exported from blender using the default or meter object scale will be close to 1 GL unit


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
