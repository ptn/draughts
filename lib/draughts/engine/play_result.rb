module Draughts
  module Engine
    class PlayResult
      attr_accessor :msg, :success, :ends_game

      def initialize(attrs)
        abort("No value for :success attribute") unless attrs.include? :success
        self.msg = attrs[:msg]
        self.success = attrs[:success]
        self.ends_game = attrs[:ends_game]
      end
    end
  end
end
