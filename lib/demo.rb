# frozen_string_literal: true
class IMICFPS
  class Demo
    def initialize(camera:, player:, demo:, mode:)
      @camera = camera
      @player = player
      @demo = demo
      @mode = mode

      @index= 0
      @tick = 0
      @changed = false

      if ARGV.join.include?("--playdemo")
        @data = File.exist?(demo) ? File.read("./demo.dat").lines : ""

      elsif ARGV.join.include?("--savedemo")
        @file = File.open(demo, "w")

        @last_pitch = @camera.orientation.z
        @last_yaw   = @camera.orientation.y

        at_exit { @file.close }
      end
    end

    def button_down(id)
      if recording?
        unless @last_written_index == @index
          @last_written_index = @index
          @file.puts("tick #{@index}")
        end

        @file.puts("down #{InputMapper.actions(id)}")
        @changed = true
      end
    end

    def button_up(id)
      if recording?
        unless @last_written_index == @index
          @last_written_index = @index
          @file.puts("tick #{@index}")
        end

        @file.puts("up #{InputMapper.actions(id)}")
        @changed = true
      end
    end

    def update
      play if playing?
      record if recording?

      @tick += 1
    end

    def playing?; @mode == :play; end
    def recording?; !playing?; end

    def play
      if @data[@index]&.start_with?("tick")
        if @tick == @data[@index].split(" ").last.to_i
          @index+=1

          until(@data[@index]&.start_with?("tick"))
            break unless @data[@index]

            data = @data[@index].split(" ")
            if data.first == "up"
              input = InputMapper.get(data.last.to_sym)
              key = input.is_a?(Array) ? input.first : input
              $window.current_state.button_up(key) if key

            elsif data.first == "down"
              input = InputMapper.get(data.last.to_sym)
              key = input.is_a?(Array) ? input.first : input
              $window.current_state.button_down(key) if key

            elsif data.first == "mouse"
              @camera.orientation.z = data[1].to_f
              @player.orientation.y = (data[2].to_f * -1) - 180
            else
              # hmm
            end

            @index += 1
          end
        end
      end
    end

    def record
      if @camera.orientation.z != @last_pitch || @camera.orientation.y != @last_yaw
        unless @last_written_index == @index
          @last_written_index = @index
          @file.puts("tick #{@index}")
        end

        @file.puts("mouse #{@camera.orientation.z} #{@camera.orientation.y}")
        @last_pitch = @camera.orientation.z
        @last_yaw   = @camera.orientation.y
      end

      @changed = false
      @index  += 1
    end
  end
end