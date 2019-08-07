class IMICFPS
  class Commands
    class Command
      def self.inherited(subclass)
        @list ||= []
        @commands ||= []
        @list << subclass
      end

      def self.setup
        @list ||= []
        @commands = []
        @list.each do |subclass|
          @commands << subclass.new
        end
      end

      def self.use(command, arguments, console)
        found_command = @commands.detect { |cmd| cmd.command == command.to_sym }

        if found_command
          found_command.handle(arguments, console)
        else
          console.stdin("Command <c=ff5555>#{command}</c> not found.")
        end
      end

      def group
        raise NotImplementedError
      end

      def command
        raise NotImplementedError
      end

      def handle(arguments, console)
        raise NotImplementedError
      end

      def usage
        raise NotImplementedError
      end
    end
  end
end