module Draughts
  module Engine
    class Board
      def initialize
        @pieces = init_pieces
      end

      #
      # Takes an integer in the range (1..32) and returns the piece at said
      # square.
      #
      def piece_at(pos)
        @pieces[pos - 1]
      end

      alias :[] :piece_at

      def standard_notation
        @pieces.map { |p| p.nil? ? " " : p.color.to_s[0] }.join
      end

      # Tries to move the piece at +from+ to square +to+. Returns a log of
      # consequences (capturing, crowning, etc.) or an explanation of the error.
      def play(from, to)
        if @pieces[to - 1]
          msg = "square #{to} is not empty"
          return PlayResult.new(msg, false)
        end

        unless @pieces[from - 1]
          msg = "no piece at square #{from}"
          return PlayResult.new(msg, false)
        end

        # Move and jump return nil on failure and an instance of PlayResult
        # on success.
        result = move(from, to) || jump(from, to)
        unless result
          msg = "can't neither capture nor move from #{from} to #{to}"
          result = PlayResult.new(msg, false)
        end

        result
      end

      def count(color)
        color == :black ? blacks_count : whites_count
      end

      def whites_count
        @pieces.count { |p| !p.nil? && p.color == :white }
      end

      def blacks_count
        @pieces.count { |p| !p.nil? && p.color == :black }
      end

      #
      # Sample output:
      #
      #   | w |   | w |   | w |   | w |
      # --------------------------------
      # w |   | w |   | w |   | w |   |
      # --------------------------------
      #   | w |   | w |   | w |   | w |
      # --------------------------------
      #   |   |   |   |   |   |   |   |
      # --------------------------------
      #   |   |   |   |   |   |   |   |
      # --------------------------------
      # b |   | b |   | b |   | b |   |
      # --------------------------------
      #   | b |   | b |   | b |   | b |
      # --------------------------------
      # b |   | b |   | b |   | b |   |
      # --------------------------------
      #
      def to_s
        piece_squares = @pieces.reverse
        empty_squares = [" "] * 4
        buf = []

        8.times do |row_index|
          row = piece_squares[row_index * 4, 4]

          if row_index.even?
            first  = empty_squares
            second = row
          else
            first  = row
            second = empty_squares
          end

          4.times do |col_index|
            buf << first[col_index].to_s
            buf << " | "
            buf << second[col_index].to_s
            buf << " | "
          end

          buf << "\n" + ("-" * 32) + "\n"
        end

        buf.map { |c| c == "" ? " " : c }.join
      end

      private

      def init_pieces
        pieces = []

        12.times { pieces.insert(0,  BlackPiece.new) }
        12.times { pieces.insert(20, WhitePiece.new) }

        pieces
      end

      def move(from, to)
        valid = @pieces[from - 1].valid_move? from, to
        perform_move(from, to) if valid
      end

      def jump(from, to)
        jumping = @pieces[from - 1]

        check_for_enemy = jumping.valid_jump_destination? from, to
        return unless check_for_enemy

        target = @pieces[check_for_enemy - 1]
        valid  = (!target.nil? && target.color != jumping.color)
        return unless valid

        # Capture enemy piece.
        @pieces[check_for_enemy - 1] = nil

        result = perform_move(from, to)
        result.msg = "captured enemy on #{check_for_enemy}"
        result
      end

      def perform_move(from, to)
        # move and jump invoke this method only when it's certain that the move
        # is valid.
        result = PlayResult.new
        result.success = true

        moving = @pieces[from - 1]
        @pieces[from - 1] = nil

        if moving.crowns_in? to
          @pieces[to - 1] = moving.crowned
          result.msg = "crowned"
        else
          @pieces[to - 1] = moving
          result.msg = "moved"
        end

        result
      end
    end
  end
end
