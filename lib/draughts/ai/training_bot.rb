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
    # Config::BOARD_THRESHOLD number of known moves. If there is no data 
    # available for the requested configuration, use the known board that's
    # most similar to it.
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

      # Bots by default play the starting configuration of a board.
      def initialize(color, conf="bbbbbbbbbbbb        wwwwwwwwwwww")
        @must_learn = true
        @color  = color.to_s
        set_conf(conf)
      end

      def configuration=(conf)
        set_conf(conf)
      end

      # Determine what move to play next.
      def play
        @played = knows_legals? ? random_play : most_likely_play
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
        return 0.0 unless starts_in_color? move

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
        return false unless @must_learn

        play = Play.get_or_create(@real_board, @played, @color)
        play.legal = result
        play.save

        set_most_likely_board unless result
      end

      private

      def knows_legals?
        @real_board.plays.count(color: @color, legal: true) > 0
      end

      def starts_in_color?(move)
        @board.configuration[move.origin - 1] == @color[0]
      end

      def untested_moves
        untested = (Move.all - @real_board.moves_of_color(@color)).to_a

        # Inject known legal moves of the most likely board at the beginning
        known_legals = @board.plays(color: @color, legal: true).move
        known_illegals = @real_board.plays(color: @color, legal: false).move
        inject = known_legals - known_illegals
        untested.unshift(*inject)

        untested.select { |ut| starts_in_color? ut }
      end

      def random_play
        @must_learn = false
        @real_board.plays(color: @color, legal: true).sample.move
      end

      #
      # Find the move that's most likely to be legal.
      #
      # Based on the results of Bayes theorem applied to the training data,
      # chooses the move that has the highest probability of being legal in the
      # current board configuration.
      #
      def most_likely_play
        @must_learn = true
        best_move = nil
        max = 0

        untested_moves.each do |ut|
          prob = probability_of(ut)
          return ut if prob >= Config::PROBS_THRESHOLD
          if max < prob
            max = prob
            best_move = ut
          end
        end

        best_move
      end

      def set_conf(conf)
        @conf = conf
        @real_board = Board.get_or_create(@conf)
        set_most_likely_board
      end

      def set_most_likely_board
        @board  = Board.get_this_or_most_alike(@conf)
        @factor = Board.similarity_factor(@conf, @board.configuration)
      end

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
        count = @board.plays.count(:legal => opts[:legal])
        count + Config::SMOOTHER * opts[:multiplier]
      end
    end
  end
end
