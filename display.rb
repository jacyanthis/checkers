require_relative 'board'
require_relative 'cursor_input'
require "colorize"


class Display
  attr_accessor :cursor, :board, :game

  def initialize(board, game)
    @board = board
    @cursor = [0, 0]
    @game = game
  end

  def game_over_message
    render
    if board.checkmate?(game.current_color)
      puts "Checkmate, #{board.opponent_color(current_color)} wins."
    else
      puts "It's a stalemate!"
    end
  end

  def display_modes
    system 'clear'
    puts "Select your mode from the following:"
    puts "1 - Player vs. Player"
    puts "2 - Player vs. Computer"
    puts "3 - Computer vs. Computer"
    puts "4 - Load a game"
  end

  def find_captured(color)
    result = ""
    board.captured_pieces.select { |piece| piece.color == color}.each do |piece|
      result += piece.to_s
    end

    result
  end

  def render(first_pos = nil)
    system("clear")
    if first_pos.nil?
      highlighted_positions = board[cursor].moves
    else
      highlighted_positions = board[first_pos].moves
    end

    puts "  #{('A'..'H').to_a.join("  ")}"


    (0...8).each do |row_idx|
      print "#{row_idx + 1}"
      (0...8).each do |col_idx|
        if cursor == [row_idx, col_idx]
          print board[[row_idx, col_idx]].to_s.colorize(:background => :light_green)
        elsif highlighted_positions.include?([row_idx, col_idx])
          print board[[row_idx, col_idx]].to_s.colorize(:background => :cyan)
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
      render(first_pos)
      # puts "i am in a new cursor loop"

      if move_type == :pick
        puts "Please select a piece to move, #{game.current_color}."
        puts
      elsif move_type == :place
        puts "Please select a location to move that piece."
        puts "You can under your piece selection by pressing 'u'."
      elsif move_type == :next_jump
        puts "You must jump again! Please select a landing position."
      end
      puts ""
      puts "Please use the arrow keys to select a position."
      puts "Press 'enter' to select a piece or a move location."
      puts "Press 's' to save or 'q' to quit."
      command = show_single_key
      if command == :return
        return cursor.dup if move_type == :pick &&
                              board[cursor].color == game.current_color
        return cursor.dup if move_type == :place &&
                              board[first_pos].moves.include?(cursor)
        return cursor.dup if move_type == :next_jump &&
                              board[first_pos].moves.include?(cursor)
      elsif command == :"\"s\""
        raise "saving not implemented yet!"
      elsif command == :"\"q\""
        exit 0
      elsif command == :"\"u\""
        raise ResetError.new
      elsif command == :up && board.on_board?([cursor[0] - 1, cursor[1]])
        self.cursor[0] -= 1
      elsif command == :down && board.on_board?([cursor[0] + 1, cursor[1]])
        self.cursor[0] += 1
      elsif command == :left && board.on_board?([cursor[0], cursor[1] - 1])
        self.cursor[1] -= 1
      elsif command == :right && board.on_board?([cursor[0], cursor[1] + 1])
        self.cursor[1] += 1
      end
    end
  end

end
