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
  OpenGL.load_lib("libGL.so", "/usr/lib/x86_64-linux-gnu")
  GLU.load_lib("libGLU.so", "/usr/lib/x86_64-linux-gnu")
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
require_relative "lib/managers/shader_manager"
require_relative "lib/managers/object_manager"
require_relative "lib/managers/light_manager"
require_relative "lib/managers/network_manager"

require_relative "lib/renderer/renderer"
require_relative "lib/renderer/shader"
require_relative "lib/renderer/opengl_renderer"
require_relative "lib/renderer/bounding_box_renderer"

require_relative "lib/states/game_state"
require_relative "lib/states/game_states/loading_state"
require_relative "lib/states/game_states/game"
require_relative "lib/states/menu"
require_relative "lib/states/menus/main_menu"

require_relative "lib/objects/text"
require_relative "lib/objects/multi_line_text"
require_relative "lib/objects/game_object"
require_relative "lib/objects/model_loader"
require_relative "lib/objects/light"

require_relative "lib/objects/game_objects/camera"
require_relative "lib/objects/game_objects/player"
require_relative "lib/objects/game_objects/tree"
require_relative "lib/objects/game_objects/skydome"
require_relative "lib/objects/game_objects/test_object"
require_relative "lib/objects/game_objects/terrain"

require_relative "lib/wavefront/model"

require_relative "lib/window"

MODEL_METER_SCALE = 0.001 # Objects exported from blender using the millimeter object scale will be close to 1 GL unit


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
