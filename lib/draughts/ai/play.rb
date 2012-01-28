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
    end
  end
end
