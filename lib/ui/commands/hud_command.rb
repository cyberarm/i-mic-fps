# frozen_string_literal: true

class IMICFPS
  class Commands
    class HUDCommand < Command
      def group
        :global
      end

      def command
        :hud
      end

      def setup
        $window.config[:options, :hud] = true if $window.config.get(:options, :hud).nil?
      end

      def handle(arguments, console)
        if arguments.size > 1
          console.stdin("to many arguments for #{Style.highlight(command.to_s)}, got #{Style.error(arguments.size)} expected #{Style.notice(1)}.")
          return
        end

        case arguments.last
        when "", nil
          console.stdin("#{Style.highlight(command.to_s)}: #{$window.config.get(:options, command)}")
        when "on"
          var = $window.config[:options, command] = true
          console.stdin("fps => #{Style.highlight(var)}")
        when "off"
          var = $window.config[:options, command] = false
          console.stdin("fps => #{Style.highlight(var)}")
        else
          console.stdin("Invalid argument for #{Style.highlight(command.to_s)}, got #{Style.error(arguments.last)} expected #{Style.notice('on')}, or #{Style.notice('off')}.")
        end
      end

      def usage
        "#{Style.highlight('hud')} #{Style.notice('[on|off]')}"
      end
    end
  end
end
