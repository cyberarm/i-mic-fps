# frozen_string_literal: true

require "json"
require "tmpdir"
require "fileutils"

require "zip"
require "excon"
require "releasy"
require "bundler/setup" # Releasy requires that your application uses bundler.
require_relative "lib/version"

Releasy::Project.new do
  name IMICFPS::NAME
  version IMICFPS::VERSION

  executable "i-mic-fps.rb"
  files ["lib/**/*.*", "assets/**/*.*", "blends/**/*.*", "shaders/**/*.*", "static/**/*.*", "maps/**/*.*", "data/**/*.*"]
  exclude_encoding # Applications that don't use advanced encoding (e.g. Japanese characters) can save build size with this.
  verbose

  add_build :windows_folder do
    icon "static/icon.ico"
    executable_type :console # Assuming you don't want it to run with a console window.
    add_package :exe # Windows self-extracting archive.
  end
end
