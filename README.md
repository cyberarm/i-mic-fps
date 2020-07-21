![Ruby](https://github.com/cyberarm/i-mic-fps/workflows/Ruby/badge.svg)
![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/cyberarm/i-mic-fps?include_prereleases)
![GitHub repo size](https://img.shields.io/github/repo-size/cyberarm/i-mic-fps)

# I-MIC FPS
![logo](https://raw.githubusercontent.com/cyberarm/i-mic-fps/master/svg/logo.svg)

Creating a multiplayer first-person-shooter in pure Ruby; Using C extensions only for Rendering, Sound, and Input. ([Gosu](https://libgosu.org) and [opengl-bindings](https://github.com/vaiorabbit/ruby-opengl/))

![screenshot](https://raw.githubusercontent.com/cyberarm/i-mic-fps/master/screenshots/screenshot-game.png)

## Using
Requires a Ruby runtime that supports the gosu and opengl-bindings C-extensions (truffleruby 1.0.0-rc12 did not work when tested. Rubinus was not tested.)
* Clone or download this repo
* `bundle install`
* `bundle exec ruby i-mic-fps.rb [options]`

### Options
* `--native` - Launch in fullscreen using primary displays resolution
* `--profile` - Run ruby-prof profiler
* `--mesa-override` - (Linux) Force MESA to use OpenGL/GLSL version 3.30
* `--savedemo` - Record camera movement and key events to playback later *(alpha-quality feature)*
* `--playdemo` - Plays the previously recorded demo *(alpha-quality feature)*
