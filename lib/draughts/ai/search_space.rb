module Draughts
  module AI
    #
    # Value class that contains the moves to be tested for validity, in order.
    #
    # After retrieving every move whose validity is not known for the current
    # board, this class injects the known legal moves of the most alike board
    # at the beginning of the result, because they have greater chance of being
    # legal in the real board.
    #
    class SearchSpace
      def initialize(board, most_alike_board, color)
        self.board = board
        self.most_alike_board = most_alike_board
        self.color = color

        build_moves
      end

      def each
        moves.each { |move| yield move }
      end

      private

      attr_accessor :moves, :board, :most_alike_board, :color

      # TODO shift calculations to sql
      def build_moves
        moves = (Move.all - board.moves_of_color(color)).to_a

        moves.unshift(*valid_known_legals)

        self.moves = moves.select do |move|
          most_alike_board.square_is_color? move.origin, color
        end
      end

      def valid_known_legals
        known_legals = most_alike_board.plays(color: color, legal: true).move
        known_illegals = board.plays(color: color, legal: false).move
        known_legals - known_illegals
      end
    end
  end
end
