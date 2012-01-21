module Draughts
  module AI
    class Move
      include DataMapper::Resource

      property :id,          Serial
      property :origin,      Integer
      property :destination, Integer

      validates_numericality_of :origin,      :gte => 1, :lte => 32
      validates_numericality_of :destination, :gte => 1, :lte => 32

      has n, :plays
      has n, :boards, :through => :plays

      def to_s
        "(#{origin}, #{destination})"
      end

    end
  end
end
