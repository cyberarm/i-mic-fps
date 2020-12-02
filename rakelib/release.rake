# frozen_string_literal: true

PACKAGING_LOCKFILE = File.expand_path("i-mic-fps-packaging.lock", Dir.tmpdir)
GITHUB_API_URL = "https://api.github.com/repos/cyberarm/i-mic-fps"
USERAGENT = "cyberarm +i-mic-fps"
DEFAULT_HEADERS = { "Authorization": "token #{ENV['GITHUB_TOKEN']}", "User-Agent": USERAGENT }.freeze

def sh_with_status(command)
  outbuf = IO.popen(command, err: %i[child out], &:read)
  status = $CHILD_STATUS

  [outbuf, status]
end

def version
  IMICFPS::VERSION
end

def version_tag
  "v#{version}"
end

def release_name
  "#{IMICFPS::NAME}_#{version}".downcase.gsub(/[\ |\-|.]/, "_")
end

def clean?
  sh_with_status("git diff --exit-code")[1].success?
end

def committed?
  sh_with_status("git diff-index --quiet --cached HEAD")[1].success?
end

def guard_clean
  clean? && committed? || abort("  There are files that need to be committed.")
end

def tag_version
  sh "git tag -m \"Version #{version}\" #{version_tag}"
  puts "   Tagged #{version_tag}."
rescue RuntimeError
  puts "  Untagging #{version_tag} due to error."
  sh_with_status "git tag -d #{version_tag}"
  abort
end

def already_tagged?
  return false unless sh_with_status("git tag")[0].split(/\n/).include?(version_tag)

  abort "  Tag #{version_tag} has already been created."
end

def create_lockfile
  File.open(PACKAGING_LOCKFILE, "w") { |f| f.write version }
end

def remove_lockfile
  File.delete(PACKAGING_LOCKFILE)
rescue Errno::ENOENT
end

def create_directory(dir)
  levels = dir.split("/")
  location = ""
  levels.each do |level|
    location += "#{level}/"
    mkdir_p location unless File.exist?(location)
  end
end

def build_package(path)
  abort "  Package folder already exists!" if File.exist?(path)
  sh "rake build:windows:folder"
end

def patch_windows_package(folder)
  patch = "require_relative \"i-mic-fps/i-mic-fps\""
  patch_file = "#{folder}/src/i-mic-fps.rb"

  File.open(patch_file, "w") { |f| f.write patch }
end

def create_archive(folder, archive)
  abort "  Archive already exists!" if File.exist?(archive)
  Zip::File.open(archive, Zip::File::CREATE) do |zipfile|
    Dir["#{folder}/**/**"].each do |file|
      zipfile.add(file.sub("#{folder}/", ""), file)
    end
  end
end

def get_release
  url = "#{GITHUB_API_URL}/releases"
  request = Excon.get(url, headers: DEFAULT_HEADERS)

  if request.status == 200
    JSON.parse(request.body).find { |r| r["tag_name"] == version_tag }

  else
    abort "  Getting repo releases failed! (#{request.status})"
  end
end

def upload_asset(asset)
  github_token = ENV["GITHUB_TOKEN"]
  abort "  GITHUB_TOKEN not set!" unless github_token

  release = get_release
  upload_url = release["upload_url"].split("{?").first + "?name=#{asset.split('/').last}"

  file = File.read(asset)

  headers = DEFAULT_HEADERS
  headers["Content-Type"] = "application/zip"
  headers["Content-Length"] = file.size

  request = Excon.post(upload_url, body: file, headers: headers)
  abort "  Upload failed! #{request.body} (#{request.status})" unless request.status.between?(200, 201)
end

namespace "game" do
  desc "Create git tag, build, and release package"
  task release: [
    "release:check_diff",
    "release:tag",
    "release:package",
    "release:patch",
    "release:create_archive",
    "release:deploy"
  ] do
  end

  desc "Check working directory for uncommited changes"
  task "release:check_diff" do
    puts "Checking for uncommited changes..."
    guard_clean
  end

  desc "Create release version tag"
  task "release:tag" do
    puts "Checking git tag for #{version_tag}..."
    already_tagged?
    puts "Committing git tag #{version_tag}..."
    tag_version
    puts "Pushing changes..."
    sh "git push origin master"
    sh "git push origin master --tags"
  end

  path = File.expand_path("../pkg/#{release_name}_WIN32", __dir__)

  desc "Create package"
  task "release:package" do
    puts "Building release package '#{release_name}', this may take a while..."
    create_lockfile
    build_package(path)
    remove_lockfile
  end

  desc "Apply patches"
  task "release:patch" do
    puts "Patching..."
    patch_windows_package(path)
  end

  desc "Create compressed zip file for deployment"
  task "release:create_archive" do
    puts "Creating archive..."
    create_archive(path, "#{path}.zip")
  end

  desc "Publish archive to github releases"
  task "release:deploy" do
    puts "Pushing package to github..."
    upload_asset("#{path}.zip")
    puts "Done."
  end

  desc "Remove lockfile"
  task "release:remove_lockfile" do
    puts "Removing #{PACKAGING_LOCKFILE}..."
    remove_lockfile
  end

  desc "Remove packaging assets"
  task "release:cleanup" do
    path = File.expand_path("../pkg", __dir__)

    if File.exist?(path)
      puts "Cleaning up..."

      Dir["#{path}/**"].each do |file|
        puts "Removing #{file}..."
        if File.directory?(file)
          FileUtils.remove_entry_secure(file)
        else
          File.delete(file)
        end
      end

      puts "Done."
    end
  end
end
