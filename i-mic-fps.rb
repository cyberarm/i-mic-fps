require "opengl"
require "glu"
require "gosu"

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

$debug = ARGV.join.include?("--debug") ? true : false

require_relative "lib/common_methods"
require_relative "lib/managers/object_manager"
require_relative "lib/managers/light_manager"

require_relative "lib/objects/light"
require_relative "lib/objects/camera"
require_relative "lib/objects/model"

require_relative "lib/wavefront/model"

require_relative "lib/window"

MODEL_METER_SCALE = 0.001 # Objects exported from blender using the millimeter object scale will be close to 1 GL unit

IMICFPS::Window.new.show
