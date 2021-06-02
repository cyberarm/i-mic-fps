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
  file_order = []

  loop do
    failed = []
    first_name_error = nil

    files.each do |file|
      begin
        require_relative file
        file_order << file
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

  # pp file_order.map { |f| f.gsub(".rb", "")}
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
else
  native = ARGV.join.include?("--native")
  fps_target = ARGV.first.to_i != 0 ? ARGV.first.to_i : 60
  window_width = native ? Gosu.screen_width : 1280
  window_height = native ? Gosu.screen_height : 720
  window_fullscreen = native ? true : false

  window = IMICFPS::Window.new(
    width: window_width,
    height: window_height,
    fullscreen: window_fullscreen,
    resizable: !window_fullscreen,
    update_interval: 1000.0 / fps_target
  )

  if ARGV.join.include?("--profile")
    begin
      require "ruby-prof"
      RubyProf.start

      window.show

      result  = RubyProf.stop
      printer = RubyProf::MultiPrinter.new(result)
      printer.print(path: ".", profile: "profile", min_percent: 2)
    rescue LoadError
      puts "ruby-prof not installed!"
      raise
    end
  else
    window.show
  end
end
