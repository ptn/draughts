require_relative '../../../config/bots'

module Draughts
  module AI

    #
    # A bot that tries to discover the rules of the game.
    #
    # The bot is given the configuration of a board (what piece is in every of
    # the playable squares) and it finds the move that's most likely to be
    # legal, according to the following algorithm:
    #
    # 1) Load a usable board. For a board to be usable, it must have at least
    # Config::TRESHOLD number of known moves. If nothing is known about the
    # configuration passed to the bot, use the known board that's most similar
    # to it.
    #
    # 2) Choose from the set of untested moves that which has the highest
    # probability of being legal.
    #
    # Once the move has been played, the register method should be invoked to
    # record whether the last move was legal or illegal.
    #
    class TrainingBot

      def initialize(conf)
        @board = Board.get_this_or_most_alike(conf)
        @conf = conf
      end

      #
      # Find the move that's most likely to be legal.
      #
      # Based on the results of Bayes theorem applied to the training data,
      # chooses the move that has the highest probability of being legal in the
      # current board configuration.
      #
      def play
        best_move = nil
        max       = 0

        untested = Move.all()
        untested.each do |ut|
          prob = probability_of(ut)
          best_move = ut if max < prob
        end

        best_move
      end

      #
      # Calculate the probability of a single move being legal.
      #
      # What needs to be calculated is the probability of a move of being
      # legal, or:
      #
      #         P(legal / move)
      #
      # Applying Bayes theorem, this expands to:
      #
      #     P(move / legal) * P(legal)
      #     --------------------------
      #            P(move)
      #
      # Since moves are comprised of two components, an origin and a
      # destination, which are independent (knowing what value one has does not
      # give you information to guess what the other might be), the
      # calculation can be further expanded into:
      #
      #      P(origin / legal) * P(destination / legal) * P(legal)
      #      -----------------------------------------------------
      #                  P(origin) * P(destination)
      #
      # Finally, using the theorem of total probability, the denominator can be
      # expanded into the sum of
      #
      #      P(origin / legal) * P(destination / legal) * P(legal)
      #
      # and
      #
      #      P(origin / illegal) * P(destination / illegal) * P(illegal)
      #
      # This last expansion is what this method calculates.
      #
      # To account for the fact that training data might be incomplete, each
      # probability is calculated using the Laplacian smoother found in
      # Config::SMOOTHER.
      #
      def probability_of(move)
        pol = prob_of_origin_being_legal(move.origin)
        pdl = prob_of_dest_being_legal(move.destination)
        pl  = prob_of_legal
        poi = prob_of_origin_being_illegal(move.origin)
        pdi = prob_of_dest_being_illegal(move.destination)
        pi  = prob_of_illegal

        numerator   = pol * pdl * pl
        denominator = numerator + poi * pdi * pi

        numerator / denominator
      end

      def register(result)
      end

      private

      def prob_of_origin_being_legal(origin)
        raw_count      = @board.count_origin_in_legal(origin)
        smoothed_count = raw_count + Config::SMOOTHER

        smoothed_legals = smoothed :legal => true,
          :multiplier => @board.distinct_origin_count

        smoothed_count.to_f / smoothed_legals.to_f
      end

      def prob_of_dest_being_legal(dest)
        raw_count      = @board.count_destination_in_legal(dest)
        smoothed_count = raw_count + Config::SMOOTHER

        smoothed_legals = smoothed :legal => true,
          :multiplier => @board.distinct_destination_count

        smoothed_count.to_f / smoothed_legals.to_f
      end

      def prob_of_origin_being_illegal(origin)
        raw_count      = @board.count_origin_in_illegal(origin)
        smoothed_count = raw_count + Config::SMOOTHER

        smoothed_illegals = smoothed :legal => false,
          :multiplier => @board.distinct_origin_count

        smoothed_count.to_f / smoothed_illegals.to_f
      end

      def prob_of_dest_being_illegal(dest)
        raw_count      = @board.count_destination_in_illegal(dest)
        smoothed_count = raw_count + Config::SMOOTHER

        smoothed_illegals = smoothed :legal => false,
          :multiplier => @board.distinct_destination_count

        smoothed_count.to_f / smoothed_illegals.to_f
      end

      def prob_of_legal
        raw_count = @board.plays.count(:legal => true)
        smoothed_count = raw_count + Config::SMOOTHER

        moves          = @board.moves.count
        smoothed_moves = moves + Config::SMOOTHER * 2

        smoothed_count.to_f / smoothed_moves.to_f
      end

      def prob_of_illegal
        raw_count = @board.plays.count(:legal => false)
        smoothed_count = raw_count + Config::SMOOTHER

        moves          = @board.moves.count
        smoothed_moves = moves + Config::SMOOTHER * 2

        smoothed_count.to_f / smoothed_moves.to_f
      end

      def smoothed(opts)
        count    = @board.plays.count(:legal => opts[:legal])
        count + Config::SMOOTHER * opts[:multiplier]
      end
    end
  end
end
