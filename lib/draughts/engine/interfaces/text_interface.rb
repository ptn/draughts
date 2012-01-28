module Draughts
  module Engine
    module Interfaces
      class TextInterface
        def start_game
          @game = Game.new
          print_new_game_message
          game_loop
        end

        private

        def print_new_game_message
          puts <<-MSG

            Game starting.

            Standard notation is used for entering moves:
            The black squares are labeled from 1 to 32 starting
            in the bottom right and ending in the top left.
            These are the numbers you have to input to make moves.
            Some examples:

            black> 9 14
            white> 21 17
            black> 14 21
          MSG
          puts
        end

        def game_loop
          loop do
            origin, dest = read_input
            result = @game.play(origin, dest)

            if result.success
              print_success(result.msg)
            else
              print_invalid(result.msg)
            end

            break if result.ends_game
          end

          print_result
        end

        def print_result
          puts "#{@game.turn}s wins!"
        end

        #FIXME ugly and repetitive
        def read_input
          ask_input
          raw = gets.chomp.split.map &:to_i

          while raw.length != 2
            ask_input("please enter 2 numbers")
            raw = gets.chomp.split.map &:to_i
          end

          raw
        end

        def ask_input(msg=nil)
          puts
          print_invalid(msg) if msg
          puts @game
          puts
          print "#{@game.turn.to_s}> "
        end

        def print_success(msg)
          puts "OK: #{msg.upcase}"
          puts
        end

        def print_invalid(msg)
          puts "INVALID: #{msg.upcase}"
          puts
        end

      end
    end
  end
end
