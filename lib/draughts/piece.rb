require 'draughts/utils'

module Draughts
  class Piece
    attr_reader :color

    def initialize
      @king = false
    end

    def crown
      @king = true
    end

    def king?
      @king
    end

    def to_s
      @color.to_s[0].capitalize
    end
  end

  class BlackPiece < Piece
    def initialize
      super
      @color = :black
    end

    def valid_move?(from, to)
      row = Utils.index_to_row(from)

      if row.even?
        [from + 3, from + 4].include? to
      else
        [from + 4, from + 5].include? to
      end
    end
  end

  class WhitePiece < Piece
    def initialize
      super
      @color = :white
    end

    def valid_move?(from, to)
      row = Utils.index_to_row(from)

      if row.even?
        [from + -4, from + -5].include? to
      else
        [from + -3, from + -4].include? to
      end
    end
  end
end
