module Draughts
  class Game
    def start
      @board = Board.new
      @turn = :blacks
      loop
    end

    def print_result
      winner = next_turn.to_s.capitalize
      puts "#{winner} wins!"
    end

    def input
      [read_origin, read_dest]
    end

    private

    def loop
      puts @board

      #TODO Check if the player has available moves, terminate if not.
      while @board.count(@turn) > 0
        puts "#{@turn.to_s.capitalize} move"

        origin, dest = input
        @board.move(origin, dest)

        @turn = next_turn

        puts @board
      end

      print_result
    end

    def next_turn
      @turn == :blacks ? :whites : :blacks
    end

    def read_origin
      print "Which piece would you like to move? Enter it's position: "
      origin = gets.to_i
      correct_position(origin)
    end

    def read_dest
      print "Where would you like to move it? "
      dest = gets.to_i
      correct_position(dest)
    end

    def correct_position(pos)
      while !(1..32).include? pos
        print "Invalid position, try again: "
        pos = gets.to_i
      end

      pos
    end

  end
end
