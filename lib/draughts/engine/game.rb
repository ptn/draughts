module Draughts
  module Engine
    class Game
      def initialize
        @board = Board.new
        @turn  = :black
      end

      def start
        print_new_game_message
        loop
      end

      def print_result
        next_turn
        puts "#{@turn}s wins!"
      end

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

      private

      def loop
        #TODO Check if the player has available moves, terminate if not.
        while @board.count(@turn) > 0
          origin, dest = read_input
          result, msg = @board.play(origin, dest)

          puts "\n\n#{msg.upcase}\n\n"
          unless result
            redo
          end

          next_turn
        end

        print_result
      end

      def ask_input(msg="")
        puts
        puts "--------------------------------"
        puts
        puts msg.upcase
        puts
        puts @board
        puts
        print "#{@turn.to_s}> "
      end

      def next_turn
        @turn = @turn == :black ? :white : :black
      end

      # ugly?
      def read_input
        ask_input
        raw = gets.chomp.split.map &:to_i

        while (error_msg = validate_input(raw))
          ask_input(error_msg)
          raw = gets.chomp.split.map &:to_i
        end

        raw
      end

      def validate_input(raw)
        msg = "Invalid move: "

        case
          when raw.length != 2
            msg += "input 2 numbers"
          when raw.any? { |coord| !(1..32).include? coord }
            msg += "numbers must be in the range from 1 to 32"
          when @board[raw[0]].color != @turn
            msg += "the piece in square #{raw[0]} is not #{@turn}"
          else
            msg = nil
        end

        msg
      end
    end
  end
end
