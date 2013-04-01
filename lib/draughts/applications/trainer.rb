require 'optparse'

require_relative '../../../config/bots'
require_relative '../../draughts'

module Draughts
  module Applications
    class Trainer
      def initialize(argv)
        @game = Engine::Game.new
        @players = [
          Draughts::AI::TrainingBot.new(:black),
          Draughts::AI::TrainingBot.new(:white),
        ]
        @log, @options = parse_options(argv)
      end

      def run
        puts "Starting game..."
        log_board(@game)

        loop do
          current_player = @players.shift
          log "It's #{current_player.color}'s turn"

          move = current_player.play
          log "#{current_player.color} played #{move}"

          result = @game.play(move.origin, move.destination)
          current_player.learn(result.success)
          log "#{move} was #{result.success ? "" : "not"} legal. Learned."

          if result.success
            @players.push(current_player)
            # Tell the bots what board they have to play.
            @players.each { |p| p.configuration = @game.standard_notation }
          else
            @players.unshift(current_player)
          end

          break if result.ends_game
          log_board(@game)
        end

        puts "#{@players.last.color} won!"
        @log.close
      end

      private

      def log(msg="")
        return if @options[:quiet]
        @log.write(msg)
        @log.write("\n")
        @log.flush
        gets if @log == $stdout && @options[:pause]
      end

      def log_board(game)
        log "Board is now:\n\n" + game.to_s
      end

      def parse_options(argv)
        logfile = nil
        options = {}
        options[:quiet] = false
        options[:pause] = false

        parser = OptionParser.new
        parser.on("-p") { options[:pause] = true }
        parser.on("-q") { options[:quiet] = true }
        parser.on("--output=FILE") { |file| logfile = file }
        parser.parse(argv)

        log = logfile ? File.open(File.expand_path(logfile), "a") : $stdout

        [log, options]
      end
    end
  end
end
