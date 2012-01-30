require_relative '../engine'
require_relative '../engine/interfaces/text_interface'

module Draughts
  module Applications
    class HumanVsHuman
      def initialize
        @cli = Draughts::Engine::Interfaces::TextInterface.new
      end

      def run
        @cli.start_game
      end
    end
  end
end
