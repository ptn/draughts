module Draughts
  module AI
    class Play
      include DataMapper::Resource

      property :id,    Serial
      property :legal, Boolean
      property :color, String

      validates_within :color, :set => ["black", "white"]

      belongs_to :board
      belongs_to :move

      def self.get_or_create(board, move, color)
        play = self.first(board: board, move: move, color: color)
        unless play
          play = self.create(board: board, move: move, color: color)
        end
        play
      end
    end
  end
end
