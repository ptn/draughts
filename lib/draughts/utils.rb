module Draughts
  module Utils
    # Takes an index in standard notation and returns the
    # row it belongs to.
    def self.index_to_row(index)
      answer = index / 4
      answer += 1 if index % 4 != 0
      answer
    end
  end
end
