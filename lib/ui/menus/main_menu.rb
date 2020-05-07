class IMICFPS
  class MainMenu < Menu
    def setup
      title IMICFPS::NAME

      link "Single Player" do
        push_state(LevelSelectMenu)
        # push_state(LoadingState.new(forward: Game, map_file: GAME_ROOT_PATH + "/maps/test_map.json"))
      end

      link "Multiplayer" do
        push_state(MultiplayerMenu)
      end

      link "Settings" do
        push_state(SettingsMenu)
      end

      link "Extras" do
        push_state(ExtrasMenu)
      end

      link "Exit Game" do
        window.close
      end

      gl_version = glGetString(GL_VERSION).to_s
      major, minor = gl_version.split(" ").first.split(".").map { |v| v.to_i }
      unless (major == 3 && minor >= 3) || (major > 3)
message =
"<b><c=f00>[Notice]</c></b> Your computer is reporting support for <b><c=f50>OpenGL #{major}.#{minor}</c></b>,
however <b><c=5f5>OpenGL 3.3 or higher is required.</c></b>

Fallback <b>immediate mode renderer</b> will be used."

linux_mesa_message =
"

(Linux Only) For MESA based drivers append <b>--mesa-override</b>
as a commandline argument to override reported version."
        message += linux_mesa_message if RUBY_PLATFORM =~ /linux/ && gl_version.downcase.include?(" mesa ")
        @old_gl_warning = Gosu::Image.from_markup(message, 24, align: :center)
      end
    end

    def draw
      super

      if @old_gl_warning
        @old_gl_warning.draw(window.width / 2 - @old_gl_warning.width / 2, window.height - (@old_gl_warning.height + 10), Float::INFINITY)
      end
    end
  end
end
