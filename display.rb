require_relative 'board'
require_relative 'cursor_input'
require "colorize"


class Display
  attr_accessor :pos, :board, :game

  def initialize(board, game)
    @board = board
    @pos = [0, 0]
    @game = game
  end

  def find_captured(color)
    result = ""
    board.captured_pieces.select{ |piece| piece.color == color}.each do |piece|
      result += piece.to_s
    end

    result
  end

  def render
    system("clear")

    puts "  #{('A'..'H').to_a.join("  ")}"


    (0...8).each do |row_idx|
      print "#{row_idx + 1}"
      (0...8).each do |col_idx|
        if pos == [row_idx, col_idx]
          print board[[row_idx, col_idx]].to_s.colorize(:background => :light_green)
        elsif board[pos].moves.include?([row_idx, col_idx])
          if board[[row_idx, col_idx]].occupied?
            print board[[row_idx, col_idx]].to_s.colorize(:background => :yellow)
          else
            print board[[row_idx, col_idx]].to_s.colorize(:background => :cyan)
          end
        elsif (row_idx + col_idx).even?
          print board[[row_idx, col_idx]].to_s.colorize(:background => :white)
        else
          print board[[row_idx, col_idx]].to_s.colorize(:background => :light_blue)
        end
      end

      if row_idx == 0
        print find_captured(:black)
      elsif row_idx == 7
        print find_captured(:red)
      end
      puts
    end
  end

  def cursor_loop(move_type, first_pos = nil)
    loop do
      render
      # puts "i am in a new cursor loop"

      if move_type == :pick
        puts "Please select a piece to move, #{game.current_color}."
        puts
      elsif move_type == :place
        puts "Please select a location to move the piece from #{first_pos}"
        puts "You can move it to any of these locations: #{board[first_pos].moves}"
      elsif move_type == :next_jump
        puts "You must jump again! Please select a landing position from #{board[first_pos].moves}."
      end
      puts ""
      puts "Please use the arrow keys to select a position."
      puts "Press 'enter' to select a piece or a move location."
      puts "Press 's' to save or 'q' to quit."
      command = show_single_key
      if command == :return
        return pos.dup if move_type == :pick && board[pos].color == game.current_color
        return pos.dup if move_type == :place && board[first_pos].moves.include?(pos)
        return pos.dup if move_type == :next_jump && board[first_pos].moves.include?(pos)
      elsif command == :"\"s\""
        offer_save
        break
      elsif command == :"\"q\""
        exit 0
      elsif command == :up && board.on_board?([pos[0] - 1, pos[1]])
        self.pos[0] -= 1
      elsif command == :down && board.on_board?([pos[0] + 1, pos[1]])
        self.pos[0] += 1
      elsif command == :left && board.on_board?([pos[0], pos[1] - 1])
        self.pos[1] -= 1
      elsif command == :right && board.on_board?([pos[0], pos[1] + 1])
        self.pos[1] += 1
      end
    end
  end

end
