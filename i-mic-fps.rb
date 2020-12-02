# frozen_string_literal: true

require "fiddle"
require "yaml"
require "json"
require "abbrev"
require "time"
require "socket"
require "tmpdir"
require "securerandom"

require "opengl"
require "glu"
require "nokogiri"
require "i18n"

begin
  require_relative "../cyberarm_engine/lib/cyberarm_engine"
  require_relative "../cyberarm_engine/lib/cyberarm_engine/opengl"
rescue LoadError => e
  pp e
  require "cyberarm_engine"
  require "cyberarm_engine/opengl"
end

Dir.chdir(File.dirname(__FILE__))

include CyberarmEngine
include OpenGL
include GLU

def require_all(directory)
  files = Dir["#{directory}/**/*.rb"].sort!

  loop do
    failed = []
    first_name_error = nil

    files.each do |file|
      begin
        require_relative file
      rescue NameError => e
        failed << file
        first_name_error ||= e
      end
    end

    if failed.size == files.size
      raise first_name_error
    else
      files = failed
    end
    break if failed.empty?
  end
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

  [false, ""]
end

if prevent_launch?[0]
  puts prevent_launch?[1]
elsif ARGV.join.include?("--profile")
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
