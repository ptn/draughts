require_relative '../utils'

module Draughts
  module Engine
    class Piece
      attr_reader :color

      def crowned
        King.new(@color)
      end

      def king?
        false
      end

      def to_s
        @color.to_s[0]
      end
    end

    class BlackPiece < Piece
      def initialize
        super
        @color = :black
      end

      def valid_move?(from, to)
        row = Utils.index_to_row(from)

        return if row + 1 != Utils.index_to_row(to)

        if row.even?
          [from + 3, from + 4].include? to
        else
          [from + 4, from + 5].include? to
        end
      end

      # Returns nil if the destination is not valid for a jump, otherwise returns
      # the square that the board has to check for an enemy piece.
      def valid_jump_destination?(from, to)
        row = Utils.index_to_row(from)
        return if row + 2 != Utils.index_to_row(to)

        case to
        when from + 7
          row.even? ? from + 3 : from + 4
        when from + 9
          row.even? ? from + 4 : from + 5
        else
          nil
        end
      end

      def crowns_in?(pos)
        pos == 8
      end
    end

    class WhitePiece < Piece
      def initialize
        super
        @color = :white
      end

      def valid_move?(from, to)
        row = Utils.index_to_row(from)

        return if row - 1 != Utils.index_to_row(to)

        if row.even?
          [from - 4, from - 5].include? to
        else
          [from - 3, from - 4].include? to
        end
      end

      # Returns nil if the destination is not valid for a jump, otherwise returns
      # the square that the board has to check for an enemy piece.
      def valid_jump_destination?(from, to)
        row = Utils.index_to_row(from)
        return if row - 2 != Utils.index_to_row(to)

        case to
        when from - 7
          row.even? ? from - 4 : from - 3
        when from - 9
          row.even? ? from - 5 : from - 4
        else
          nil
        end
      end

      def crowns_in?(pos)
        pos == 1
      end
    end

    class King < Piece
      def initialize(color)
        @color = color
        @white_proxy = WhitePiece.new
        @black_proxy = BlackPiece.new
      end

      def king?
        true
      end

      def to_s
        @color.to_s[0].capitalize
      end

      def valid_move?(from, to)
        (@white_proxy.valid_move? from, to) || (@black_proxy.valid_move? from, to)
      end

      def crowns_in?(pos)
        false
      end
    end
  end
end
