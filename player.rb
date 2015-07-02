class Player
  attr_accessor :game, :display, :color

  def initialize(game, display, color)
    @game = game
    @display = display
    @color = color
  end
end

class Human < Player
  def get_move
    begin
      first_move = display.cursor_loop(:pick)
      second_move = display.cursor_loop(:place, first_move)
    rescue ResetError => u
      retry
    end
    game.execute_move([first_move, second_move])
  end

  def get_next_jump(_, jump_pos)
    display.cursor_loop(:next_jump, jump_pos)
  end
end

class Computer < Player
  attr_accessor :next_jump, :intelligence

  def initialize(game, display, color)
    super
    @next_jump = nil
    @intelligence = 2
  end

  def get_next_jump(duped_board, jump_pos)
    # puts "i am in the get_next_jump method"
    # puts "my valid jumps are #{duped_board.all_valid_jumps(jump_pos)} using my #{game.board[jump_pos].class} at #{jump_pos}"
    duped_board.all_valid_jumps(jump_pos).max_by do |move|
      new_duped_board = duped_board.deep_dup_board
      new_duped_board.execute_move(move)
      move_value = direct_value(duped_board)
      # puts "the move #{move} has a value of: #{move_value}"
      move_value
    end
  end

  def get_move
    best_move = game.board.all_valid_moves(color).max_by do |move|
      duped_board = game.board.deep_dup_board
      duped_board.execute_move(move)
      display.render
      move_value = find_value(duped_board, :self, intelligence)
      puts "i am #{color} and my move #{move} has a value of: #{move_value}"
      move_value
    end

    # puts "my best move is #{best_move}"
    game.execute_move(best_move)
    display.render
  end

  def find_value(board_state, player, depth)
    return direct_value(board_state) if depth == 0

    if player == :self
      potential_board_states(board_state, color).map do |state|
        find_value(state, :opponent, depth - 1)
      end.max
    else
      potential_board_states(board_state, color).map do |state|
        find_value(state, :self, depth - 1)
      end.min
    end
  end

  def direct_value(board_state)
    num_self_pieces = board_state.grid.flatten.select do |piece|
      piece.color == color
    end.count

    num_enemy_pieces = board_state.grid.flatten.select do |piece|
      piece.color == board_state.opposite_color(color)
    end.count

    # puts "i think the value of my board is #{num_self_pieces - num_enemy_pieces}"

    num_self_pieces - num_enemy_pieces
  end

  def potential_board_states(board_state, color)
    game.board.all_valid_moves(color).map do |move|
      duped_board = game.board.deep_dup_board
      duped_board.execute_move(move)
      duped_board
    end
  end

end

class ResetError < StandardError
end
