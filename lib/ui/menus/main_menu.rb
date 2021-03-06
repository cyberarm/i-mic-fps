# frozen_string_literal: true

class IMICFPS
  class MainMenu < Menu
    def setup
      title IMICFPS::NAME

      link I18n.t("menus.singleplayer") do
        push_state(SinglePlayerMenu)
      end

      link I18n.t("menus.multiplayer") do
        push_state(MultiplayerMenu)
      end

      link I18n.t("menus.settings") do
        push_state(SettingsMenu)
      end

      link I18n.t("menus.extras") do
        push_state(ExtrasMenu)
      end

      link I18n.t("menus.quit"), margin_top: 25 do
        window.close
      end

      gl_version = glGetString(GL_VERSION).to_s
      major, minor = gl_version.split(" ").first.split(".").map(&:to_i)
      unless (major == 3 && minor >= 3) || (major > 3)
        message =
          "<b><c=a00>[Notice]</c></b> Your computer is reporting support for <b><c=f50>OpenGL #{major}.#{minor}</c></b>,
however <b><c=5f5>OpenGL 3.3 or higher is required.</c></b>

Fallback <b>immediate mode renderer</b> will be used."

        linux_mesa_message =
          "

(Linux Only) For MESA based drivers append <b>--mesa-override</b>
as a commandline argument to override reported version."
        message += linux_mesa_message if RUBY_PLATFORM =~ /linux/ && gl_version.downcase.include?(" mesa ")
        @old_gl_warning = Text.new(message, size: 24, z: Float::INFINITY, border: true, border_color: Gosu::Color::BLACK)
      end
    end

    def draw
      super

      @old_gl_warning&.x = window.width / 2 - @old_gl_warning.width / 2
      @old_gl_warning&.y = window.height - (@old_gl_warning.height + 10)

      @old_gl_warning&.draw
    end
  end
end
