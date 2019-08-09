class IMICFPS
  class Commands
    module Style
      def self.error(string)
        "<c=ff5555>#{string}</c>"
      end
      def self.warn(string)
        "<c=ff7700>#{string}</c>"
      end
      def self.notice(string)
        "<c=55ff55>#{string}</c>"
      end
      def self.highlight(string, color = "5555ff")
        "<c=#{color}>#{string}</c>"
      end
    end

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
          cmd = subclass.new
          raise "Command '#{cmd.command}' from '#{cmd.class}' already exists!" if @commands.detect { |c| c.command == cmd.command }

          @commands << cmd
        end
      end

      def self.use(command, arguments, console)
        found_command = @commands.detect { |cmd| cmd.command == command.to_sym }

        if found_command
          found_command.handle(arguments, console)
        else
          console.stdin("Command #{Style.error(command)} not found.")
        end
      end

      def self.find(command)
        @commands.detect { |cmd| cmd.command == command.to_sym }
      end

      def self.list_commands
        @commands
      end

      def initialize
        @store = {}
        @subcommands = []

        setup
      end

      def setup; end

      def subcommand(command, type)
        raise "Subcommand '#{command}' for '#{self.command}' already exists!" if @subcommands.detect { |subcmd| subcmd.command == command.to_sym }
        @subcommands << SubCommand.new(self, command, type)
      end

      def get(key)
        @store.dig(key)
      end

      def set(key, value)
        @store[key] = value
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

      def autocomplete(console)
      end

      def handle_subcommand(arguments, console)
        if arguments.size == 0
          console.stdin(usage)
          return
        end
        subcommand = arguments.delete_at(0)

        found_command = @subcommands.detect { |cmd| cmd.command == subcommand.to_sym }
        if found_command
          found_command.handle(arguments, console)
        else
          console.stdin("Unknown subcommand #{Style.error(subcommand)} for #{Style.highlight(command)}")
        end
      end

      def usage
        raise NotImplementedError
      end
    end

    class SubCommand
      def initialize(parent, command, type)
        @parent = parent
        @command = command
        @type = type
      end

      def command
        @command
      end

      def handle(arguments, console)
        if arguments.size > 1
          console.stdin("to many arguments for #{Style.highlight("#{command}")}, got #{Style.error(arguments.size)} expected #{Style.notice(1)}.")
          return
        end

        case @type
        when :boolean
          case arguments.last
          when "", nil
            var = @parent.get(command.to_sym) ? @parent.get(command.to_sym) : false
            console.stdin("#{command}: #{Style.highlight(var)}")
          when "on"
            var = @parent.set(command.to_sym, true)
            console.stdin("#{command} => #{Style.highlight(var)}")
          when "off"
            var = @parent.set(command.to_sym, false)
            console.stdin("#{command} => #{Style.highlight(var)}")
          else
            console.stdin("Invalid argument for #{Style.highlight("#{command}")}, got #{Style.error(arguments.last)} expected #{Style.notice("on")}, or #{Style.notice("off")}.")
          end
        when :string
          case arguments.last
          when "", nil
            var = @parent.get(command.to_sym) ? @parent.get(command.to_sym) : "\"\""
            console.stdin("#{command}: #{Style.highlight(var)}")
          else
            var = @parent.set(command.to_sym, arguments.last)
            console.stdin("#{command} => #{Style.highlight(var)}")
          end
        when :integer
          case arguments.last
          when "", nil
            var = @parent.get(command.to_sym) ? @parent.get(command.to_sym) : "nil"
            console.stdin("#{command}: #{Style.highlight(var)}")
          else
            begin
              var = @parent.set(command.to_sym, Integer(arguments.last))
              console.stdin("#{command} => #{Style.highlight(var)}")
            rescue ArgumentError
              console.stdin("Error: #{Style.error("Expected an integer, got '#{arguments.last}'")}")
            end
          end
        when :decimal
          case arguments.last
          when "", nil
            var = @parent.get(command.to_sym) ? @parent.get(command.to_sym) : "nil"
            console.stdin("#{command}: #{Style.highlight(var)}")
          else
            begin
              var = @parent.set(command.to_sym, Float(arguments.last))
              console.stdin("#{command} => #{Style.highlight(var)}")
            rescue ArgumentError
              console.stdin("Error: #{Style.error("Expected a decimal or integer, got '#{arguments.last}'")}")
            end
          end
        else
          raise RuntimeError
        end
      end

      def usage
        case @type
        when :boolean
          "#{Style.highlight(command)} #{Style.notice("[on|off]")}"
        when :string
          "#{Style.highlight(command)} #{Style.notice("[string]")}"
        when :integer
          "#{Style.highlight(command)} #{Style.notice("[0]")}"
        when :decimal
          "#{Style.highlight(command)} #{Style.notice("[0.0]")}"
        end
      end
    end
  end
end