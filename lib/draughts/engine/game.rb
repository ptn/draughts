module Draughts
  module Engine
    class Game
      def start
        @board = Board.new
        @turn = :black
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
        MSG
        puts
      end

      private

      def loop
        #TODO Check if the player has available moves, terminate if not.
        while @board.count(@turn) > 0
          print_new_turn_info

          origin, dest = read_origin, read_dest
          result, msg = @board.play(origin, dest)

          puts "\n\n#{msg}\n\n"
          unless result
            redo
          end

          next_turn
        end

        print_result
      end

      def print_new_turn_info
        puts
        puts @board
        puts
        puts "#{@turn.to_s.capitalize}s move."
        puts
      end

      def next_turn
        @turn = @turn == :black ? :white : :black
      end

      def read_origin
        origin = read_position(:msg => "Which piece would you like to move? Enter it's position: ")

        while @board[origin].nil? || @board[origin].color != @turn
          origin = read_position(:msg => "It's #{@turn}'s turn, enter the position of a #{@turn} piece: ")
        end

        origin
      end

      def read_dest
        dest = read_position(:msg => "Where would you like to move it? ")

        while @board[dest]
          dest = read_position(:msg => "That square is not empty, enter a new destination: ")
        end

        dest
      end

      def read_position(opts)
        print opts[:msg]
        while !(1..32).include? (pos = gets.to_i)
          print "Invalid position, try again: "
        end

        pos
      end

    end
  end
end
