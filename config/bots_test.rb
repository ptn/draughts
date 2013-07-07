module Draughts
  module AI
    module Config
      # Minimum number of plays that must be associated to a board for it to be
      # considered for calculations and predictions.
      BOARD_THRESHOLD = 0
      PROBS_THRESHOLD = 0.6
      # Used for Laplace smoothing.
      SMOOTHER = 1
      DB_DIR   = "data"
      DB_NAME  = "draughts_test.db"
      DB_LOG   = "db_test.log"
      DB_DEBUG = false
    end
  end
end
