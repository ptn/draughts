module Draughts
  module AI
    #
    # A bot that tries to win.
    #
    class OptimizingBot

      def initialize(conf)
        @board = Board.get_most_alike(conf)
      end

      def play
        #TODO Add magical pixie dust
      end
    end
  end
end
