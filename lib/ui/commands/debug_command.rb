# frozen_string_literal: true

class IMICFPS
  class Commands
    class DebugCommand < CyberarmEngine::Console::Command
      def group
        :global
      end

      def command
        :debug
      end

      def set(key, value)
        $window.config[:debug_options, key] = value
      end

      def get(key)
        $window.config.get(:debug_options, key)
      end

      def setup
        set(:boundingboxes, false) if $window.config.get(:debug_options, :boundingboxes).nil?
        set(:wireframe, false) if $window.config.get(:debug_options, :wireframe).nil?
        set(:stats, false) if $window.config.get(:debug_options, :stats).nil?
        set(:skydome, true) if $window.config.get(:debug_options, :skydome).nil?
        set(:use_shaders, true) if $window.config.get(:debug_options, :use_shaders).nil?
        set(:opengl_error_panic, false) if $window.config.get(:debug_options, :opengl_error_panic).nil?

        subcommand(:boundingboxes, :boolean)
        subcommand(:wireframe, :boolean)
        subcommand(:stats, :boolean)
        subcommand(:skydome, :boolean)
        subcommand(:use_shaders, :boolean)
        subcommand(:opengl_error_panic, :boolean)
      end

      def handle(arguments, console)
        handle_subcommand(arguments, console)
      end

      def usage
        "debug\n    #{@subcommands.map(&:usage).join("\n    ")}"
      end
    end
  end
end
