module Draughts
  module Engine
    class Game
      attr_accessor :turn

      def initialize
        @board   = Board.new
        @turn    = :black
        @finished = false
      end

      #TODO Check if the player has available moves, terminate if not.
      def play(orig, dest)
        return if @finished

        error_msg = validate_input(orig, dest)
        return PlayResult.new(error_msg) if error_msg

        result = @board.play(orig, dest)
        if result.success
          next_turn
          if @board.count(@turn) == 0
            result.ends_game = true
            @finished = true
          end
        end
        result
      end

      def to_s
        @board.to_s
      end

      def standard_notation
        @board.standard_notation
      end

      private

      def next_turn
        @turn = @turn == :black ? :white : :black
      end

      def validate_input(orig, dest)
        case
        when !((1..32).include? orig) || !((1..32).include? dest)
          msg = "numbers must be in the range from 1 to 32"
        when @board[orig].nil?
          msg = "no piece at square #{orig}"
        when @board[orig].color != @turn
          msg = "the piece in square #{orig} is not #{@turn}"
        else
          msg = nil
        end

        msg
      end

    end
  end
end
