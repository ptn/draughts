module Draughts
  class Board
    def initialize
      @pieces = init_pieces
    end

    def count(color)
      color == :blacks ? blacks_count : whites_count
    end

    def whites_count
      @pieces.count { |p| !p.nil? && p.color == :w }
    end

    def blacks_count
      @pieces.count { |p| !p.nil? && p.color == :b }
    end

    def to_s
      piece_squares = @pieces.reverse
      empty_squares = [" "] * 4
      buf = []

      8.times do |row_index|
        row = piece_squares[row_index * 4, 4]

        if row_index.even?
          first  = empty_squares
          second = row
        else
          first  = row
          second = empty_squares
        end

        4.times do |col_index|
          buf << first[col_index].to_s
          buf << second[col_index].to_s
        end

        buf << "\n"
      end

      buf.join
    end

    private

    def init_pieces
      pieces = []

      12.times { pieces.insert(0,  Piece.new(:b)) }
      12.times { pieces.insert(20, Piece.new(:w)) }

      pieces
    end
  end
end
