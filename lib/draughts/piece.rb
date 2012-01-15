module Draughts
  class Piece
    attr_reader :color

    def initialize(color)
      @color = color
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
end
