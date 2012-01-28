require_relative '../../../config/bots'

module Draughts
  module AI

    #
    # A bot that discovers the rules of the game.
    #
    # The bot is given the configuration of a board (what piece is in every of
    # the playable squares) and it finds the move that's most likely to be
    # legal, according to the following algorithm:
    #
    # 1) Load a usable board. For a board to be usable, it must have at least
    # Config::TRESHOLD number of known moves. If there is no data available for
    # the requested configuration, use the known board that's most similar to
    # it.
    #
    # 2) Measure how similar the board loaded is to the board requested with a
    # ratio called the similarity factor.
    #
    # 3) Choose from the set of untested moves that which has the highest
    # probability of being legal, adjusted with the similarity factor.
    #
    # Once the move has been played, the learn method should be invoked to
    # record whether the last move was legal or illegal.
    #
    class TrainingBot
      attr_reader :color

      def initialize(color, conf)
        @conf   = conf
        @color  = color.to_s
        @board  = Board.get_this_or_most_alike(@conf)
        @factor = Board.similarity_factor(conf, @board.configuration)
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

        untested = Move.all - @board.moves_of_color(@color)
        untested.each do |ut|
          prob = probability_of(ut)
          if max < prob
            max = prob
            best_move = ut
          end
        end

        @played = best_move
      end

      #
      # Calculate the probability of a single move being legal.
      #
      # If the requested move starts in a square occupied by an enemy piece,
      # automatically return a probability of 0.
      #
      # If the bot is using the same board that it was requested to play
      # instead of the most similar one, then check if we alread know the
      # result for this move. If we do, return that.
      #
      # If none of those shortcuts apply, calculate the probability via Bayes
      # theorem.
      #
      def probability_of(move)
        # Can't move an enemy piece. This is the only rule that the bot knows a
        # priori.
        return 0.0 if @board.configuration[move.origin - 1] != @color[0]

        # Directly return the probability of known moves without calculations.
        if @factor == 1.0
          play = move.plays.first(:board => @board, :color => @color)
          if play
            return play.legal? ? 1.0 : 0.0
          end
        end

        bayes(move)
      end

      #
      # Register in database whether the played move was legal or illegal.
      #
      # Updates the training data with the result of the last move played. This
      # updates only the data for the configuration requested, creating a board
      # if none matches, and does nothing with the board used for the
      # calculation of the probabilities.
      #
      def learn(result)
        board  = Board.get_or_create(@conf)
        Play.create :board => board, :move => @played, :legal => result
      end

      private

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
      def bayes(move)
        pol = prob_of_origin_being_legal(move.origin)
        pdl = prob_of_dest_being_legal(move.destination)
        pl  = prob_of_legal
        poi = prob_of_origin_being_illegal(move.origin)
        pdi = prob_of_dest_being_illegal(move.destination)
        pi  = prob_of_illegal

        numerator   = pol * pdl * pl
        denominator = numerator + poi * pdi * pi

        numerator / denominator * @factor
      end

      def prob_of_origin_being_legal(origin)
        raw_count      = @board.count_origin_in_legal(origin, @color)
        smoothed_count = raw_count + Config::SMOOTHER

        smoothed_legals = smoothed(:legal => true,
          :multiplier => @board.distinct_origin_count(@color))

        smoothed_count.to_f / smoothed_legals.to_f
      end

      def prob_of_dest_being_legal(dest)
        raw_count      = @board.count_destination_in_legal(dest, @color)
        smoothed_count = raw_count + Config::SMOOTHER

        smoothed_legals = smoothed(:legal => true,
          :multiplier => @board.distinct_destination_count(@color))

        smoothed_count.to_f / smoothed_legals.to_f
      end

      def prob_of_origin_being_illegal(origin)
        raw_count      = @board.count_origin_in_illegal(origin, @color)
        smoothed_count = raw_count + Config::SMOOTHER

        smoothed_illegals = smoothed(:legal => false,
          :multiplier => @board.distinct_origin_count(@color))

        smoothed_count.to_f / smoothed_illegals.to_f
      end

      def prob_of_dest_being_illegal(dest)
        raw_count      = @board.count_destination_in_illegal(dest, @color)
        smoothed_count = raw_count + Config::SMOOTHER

        smoothed_illegals = smoothed(:legal => false,
          :multiplier => @board.distinct_destination_count(@color))

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
