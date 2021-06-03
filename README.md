![Ruby](https://github.com/cyberarm/i-mic-fps/workflows/Ruby/badge.svg)
![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/cyberarm/i-mic-fps?include_prereleases)
![GitHub repo size](https://img.shields.io/github/repo-size/cyberarm/i-mic-fps)

# I-MIC FPS
![logo](https://raw.githubusercontent.com/cyberarm/i-mic-fps/master/svg/logo.svg)

Creating a multiplayer first-person-shooter in pure Ruby; Using C extensions only for Rendering, Sound, and Input. ([Gosu](https://libgosu.org) and [opengl-bindings](https://github.com/vaiorabbit/ruby-opengl/))

![screenshot](https://raw.githubusercontent.com/cyberarm/i-mic-fps/master/screenshots/screenshot-game.png)

## Using
Ruby 3.0+ interpeter with support for the Gosu game library C extension.
* Clone or download this repo
* `bundle install`
* `bundle exec ruby i-mic-fps.rb [options]`

### System Requirements
| Minimum |                         |
| :------ | ----------------------: |
| OS      | Windows 10 or GNU/Linux |
| CPU     | Intel Core i5-3320M     |
| RAM     | 512 MB                  |
| GPU     | OpenGL 3.30 Capable     |
| Storage | To Be Determined        |
| Network | To Be Determined        |
| Display | 1280x720                |

| Recommended |                               |
| :---------- | ----------------------------: |
| OS          | Windows 10 or GNU/Linux       |
| CPU         | AMD Ryzen 5 3600              |
| RAM         | 1 GB+                         |
| GPU         | AMD Radeon RX 5700 XT         |
| Storage     | To Be Determined (< 4 GB)     |
| Network     | Broadband Internet Connection |
| Display     | 1920x1080 60Hz                |

Note: Recommended CPU and GPU are those of the primary development system and are overkill at this point.

### Options
* `--native` - Launch in fullscreen using primary displays resolution
* `--profile` - Run ruby-prof profiler
* `--mesa-override` - (Linux) Force MESA to use OpenGL/GLSL version 3.30
* `--savedemo` - Record camera movement and key events to playback later *(alpha-quality feature)*
* `--playdemo` - Plays the previously recorded demo *(alpha-quality feature)*
