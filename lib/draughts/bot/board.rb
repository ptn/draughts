require_relative '../../../config/bots'

module Draughts
  module Bot
    #
    # Represents a board in a format that bots can manipulate.
    #
    # Boards are represented in database as a string of 32 characters, where
    # each character is the content of the playable square of said index
    # according to standard notation for checkers. Black pieces are represented
    # by a b, whites by a w, and empty squares by a single whitespace
    # character; kings are represented by the corresponding capital letter. So
    # the opening position would be represented like this (dashes added for
    # clarity):
    #
    # b-b-b-b-b-b-b-b-b-b-b-b- - - - - - - - -w-w-w-w-w-w-w-w-w-w-w-w
    #
    class Board
      include DataMapper::Resource

      property :id,           Serial
      property :configuraton, String, :length => 32

      has n, :plays
      has n, :moves, :through => :plays

      #
      # Find the board in the database that's most alike the configuration
      # given.
      #
      # The search happens as follows:
      #
      # * If the board exists in database, return it if it contains a treshold
      # number of plays associated to it.
      #
      # * Otherwise, return the board that does exist that has the least
      # differences and that passes the treshold.
      #
      # * If no board passes the threshold, return nil to force the bot to play
      # at random.
      #
      # The threshold prevents the bot from working with insufficient data and
      # thus making uninformed guesses.
      #
      # The similarity between configurations is measured by comparing
      # corresponding squares and simply counting how many squares have the
      # same contents. For example:
      #
      # b-b-b- - -W-w
      #
      # is more similar to
      #
      # b-b- - - -W-w
      #
      # than to
      #
      # w-w-b- - - -w
      #
      def self.get_most_alike(conf)
        #TODO Optimize
        boards = Board.all.select { |b| b.plays.count >= Config::TRESHOLD }

        return if boards.count == 0

        board = boards.select { |b| b.configuraton == conf }.first
        unless board
          board = board_with_least_difference(conf, boards)
        end

        board
      end

      def self.difference(conf1, conf2)
        diff = 0
        32.times do |i|
          diff += 1 if conf1[i] != conf2[i]
        end

        diff
      end

      private

      #
      # Return the board whose configuration has the least differences with the
      # configuration given.
      #
      def self.board_with_least_difference(conf, boards)
        board = nil
        min_diff = 33

        boards.each do |b|
          diff = difference(conf, b.configuraton)
          if diff < min_diff
            board = b
            min_diff = diff
          end
        end

        board
      end
    end
  end
end
