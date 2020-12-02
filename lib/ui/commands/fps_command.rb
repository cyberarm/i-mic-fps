# frozen_string_literal: true
class IMICFPS
  class Commands
    class FPSCommand < Command
      def group
        :global
      end

      def command
        :fps
      end

      def handle(arguments, console)
        if arguments.size > 1
          console.stdin("to many arguments for #{Style.highlight("#{command}")}, got #{Style.error(arguments.size)} expected #{Style.notice(1)}.")
          return
        end

        case arguments.last
        when "", nil
          console.stdin("#{Style.highlight("fps")}: #{$window.config.get(:options, :fps)}")
        when "on"
          var = $window.config[:options, :fps] = true
          console.stdin("fps => #{Style.highlight(var)}")
        when "off"
          var = $window.config[:options, :fps] = false
          console.stdin("fps => #{Style.highlight(var)}")
        else
          console.stdin("Invalid argument for #{Style.highlight("#{command}")}, got #{Style.error(arguments.last)} expected #{Style.notice("on")}, or #{Style.notice("off")}.")
        end
      end

      def usage
        "#{Style.highlight("fps")} #{Style.notice("[on|off]")}"
      end
    end
  end
end
