module Draughts
  class Game
    def start
      @board = Board.new
      @turn = :black
      loop
    end

    def print_result
      winner = next_turn.to_s.capitalize
      puts "#{winner}s wins!"
    end

    def input
      [read_origin, read_dest]
    end

    private

    def loop
      #TODO Check if the player has available moves, terminate if not.
      while @board.count(@turn) > 0
        puts @board
        puts "#{@turn.to_s.capitalize}s move"

        origin, dest = input
        if !@board.move(origin, dest)
          puts "You can't move there. Repeating the turn..."
          redo
        end

        @turn = next_turn
      end

      print_result
    end

    def next_turn
      @turn == :black ? :white : :black
    end

    def read_origin
      origin = read_position(:msg => "Which piece would you like to move? Enter it's position: ")

      while @board[origin].nil? || @board[origin].color != @turn
        origin = read_position(:msg => "It's #{@turn}'s turn, try again: ")
      end

      origin
    end

    def read_dest
      dest = read_position(:msg => "Where would you like to move it? ")

      while @board[dest]
        dest = read_position(:msg => "That square is not empty, try again. Enter a new destination: ")
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
