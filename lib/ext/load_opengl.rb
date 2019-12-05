case OpenGL.get_platform
when :OPENGL_PLATFORM_WINDOWS
  OpenGL.load_lib("opengl32.dll", "C:/Windows/System32")
  GLU.load_lib("GLU32.dll", "C:/Windows/System32")
when :OPENGL_PLATFORM_MACOSX
  OpenGL.load_lib("libGL.dylib", "/System/Library/Frameworks/OpenGL.framework/Libraries")
  GLU.load_lib("libGLU.dylib", "/System/Library/Frameworks/OpenGL.framework/Libraries")
when :OPENGL_PLATFORM_LINUX
  # Black magic to get GLSL 3.30 support on older Intel hardware
  if ARGV.join.include?("--mesa-override") && `glxinfo | egrep "OpenGL vendor|OpenGL renderer"`.include?("Intel")
    ENV["MESA_GL_VERSION_OVERRIDE"] = "3.3"
    ENV["MESA_GLSL_VERSION_OVERRIDE"] = "330"
  end

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