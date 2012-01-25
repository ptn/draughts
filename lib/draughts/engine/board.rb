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


      # Tries to move the piece at +from+ to square +to+. Returns a log of
      # consequences (capturing, crowning, etc.) or an explanation of the error.
      def play(from, to)
        return false if @pieces[to - 1]
        return false unless @pieces[from - 1]

        # Move and jump return false on failure and output messages on success.
        result = move(from, to) || jump(from, to)
        if result
          [true, result]
        else
          [false, "YOU CAN'T NEITHER CAPTURE NOR MOVE FROM #{from} TO #{to}"]
        end
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

        check  = jumping.valid_jump_destination? from, to
        return unless check

        target = @pieces[check - 1]
        valid  = (!target.nil? && target.color != jumping.color)
        return unless valid

        move_result = perform_move(from, to)
        @pieces[check - 1] = nil
        "#{move_result}; CAPTURED ENEMY ON #{check}"
      end

      def perform_move(from, to)
        moving = @pieces[from - 1]
        @pieces[from - 1] = nil
        if moving.crowns_in? to
          @pieces[to - 1] = moving.crowned
          "CROWNED"
        else
          @pieces[to - 1] = moving
          "MOVED"
        end
      end
    end
  end
end
