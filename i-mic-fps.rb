require "fiddle"
require "yaml"
require "json"
require "abbrev"
require "time"
require "socket"
require "tmpdir"

require "opengl"
require "glu"
require "nokogiri"
require "async/websocket"

begin
  require_relative "../cyberarm_engine/lib/cyberarm_engine"
rescue LoadError => e
  pp e
 require "cyberarm_engine"
end

Dir.chdir(File.dirname(__FILE__))

include CyberarmEngine
include OpenGL
include GLU

def require_all(directory)
  files = Dir["#{directory}/**/*.rb"].sort!

  begin
    failed = []
    first_name_error = nil

    files.each do |file|
      begin
        require_relative file
      rescue NameError => name_error
        failed << file
        first_name_error ||= name_error
      end
    end

    if failed.size == files.size
      raise first_name_error
    else
      files = failed
    end
  end until( failed.empty? )
end

require_all "lib"

# Don't launch game if IMICFPS_SERVER_MODE is defined
# or if game is being packaged
def prevent_launch?
  packaging_lockfile = File.expand_path("i-mic-fps-packaging.lock", Dir.tmpdir)
  m = "Game client not launched"

  return [true, "#{m}: Server is running"] if defined?(IMICFPS_SERVER_MODE) && IMICFPS_SERVER_MODE

  return [true, "#{m}: Packaging is running"] if defined?(Ocra)

  if File.exist?(packaging_lockfile) && File.read(packaging_lockfile).strip == IMICFPS::VERSION
    return [true, "#{m}: Packaging lockfile is present (#{packaging_lockfile})"]
  end

  return [false, ""]
end

unless prevent_launch?[0]
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
else
  puts prevent_launch?[1]
end
