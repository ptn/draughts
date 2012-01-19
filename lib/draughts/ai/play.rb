module Draughts
  module AI
    class Play
      include DataMapper::Resource

      property :legal, Boolean

      belongs_to :board, :key => true
      belongs_to :move,  :key => true
    end
  end
end
