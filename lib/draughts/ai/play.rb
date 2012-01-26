module Draughts
  module AI
    class Play
      include DataMapper::Resource

      property :legal, Boolean
      property :color, String

      validates_within :color, :set => ["black", "white"]

      belongs_to :board, :key => true
      belongs_to :move,  :key => true
    end
  end
end
