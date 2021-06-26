# frozen_string_literal: true

class IMICFPS
  class Commands
    class FPSCommand < CyberarmEngine::Console::Command
      def group
        :global
      end

      def command
        :fps
      end

      def handle(arguments, console)
        if arguments.size > 1
          console.stdin("to many arguments for #{Console::Style.highlight(command.to_s)}, got #{Console::Style.error(arguments.size)} expected #{Console::Style.notice(1)}.")
          return
        end

        case arguments.last
        when "", nil
          console.stdin("#{Console::Style.highlight('fps')}: #{$window.config.get(:options, :fps)}")
        when "on"
          var = $window.config[:options, :fps] = true
          console.stdin("fps => #{Console::Style.highlight(var)}")
        when "off"
          var = $window.config[:options, :fps] = false
          console.stdin("fps => #{Console::Style.highlight(var)}")
        else
          console.stdin("Invalid argument for #{Console::Style.highlight(command.to_s)}, got #{Console::Style.error(arguments.last)} expected #{Console::Style.notice('on')}, or #{Console::Style.notice('off')}.")
        end
      end

      def usage
        "#{Console::Style.highlight('fps')} #{Style.notice('[on|off]')}"
      end
    end
  end
end
