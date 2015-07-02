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
    [jump_pos, display.cursor_loop(:next_jump, jump_pos)]
  end
end

class Computer < Player
  attr_accessor :next_jump, :intelligence

  def initialize(game, display, color, intelligence)
    super(game, display, color)
    @next_jump = nil
    @intelligence = intelligence #0-4 (gets slowed as intelligence increases)
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
    moves_with_values = game.board.all_valid_moves(color).map do |move|
      duped_board = game.board.deep_dup_board
      puts "my board's oid is: #{duped_board.object_id}"
      duped_board.execute_move(move)
      duped_board.special_render
      puts "i am looking for the value of this move: #{move}"
      move_value = find_value(duped_board, :self, intelligence)
      puts "i am #{color} and my move #{move} has a value of: #{move_value}"
      [move, move_value]
    end
    puts "my moves with values are: #{moves_with_values}"

    best_move_with_value = moves_with_values.max_by { |move, value| value }

    best_pairs = moves_with_values.select { |move, value| value == best_move_with_value[1]}

    best_moves = best_pairs.map { |move, value| move }
    # puts "my best move is #{best_move}"
    game.execute_move(best_moves.sample)
    display.render
  end

  def find_value(board_state, player, depth)
    # puts "i am at depth #{depth} in the recursive call"
    # puts "i am looking at this board:"
    # board_state.special_render
    # sleep(0.5)
    return direct_value(board_state) if depth == 0

    if player == :self
      values = potential_board_states(board_state, color).map do |state|
        find_value(state, :opponent, depth - 1)
      end
      puts "my values for maxing are #{values}"
      values.empty? ? find_value(board_state, :opponent, depth - 1) : values.max
    else
      values = potential_board_states(board_state, game.board.opposite_color(color)).map do |state|
        find_value(state, :self, depth - 1)
      end
      puts "my values for mining are: #{values}"
      values.empty? ? find_value(board_state, :opponent, depth - 1) : values.min
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
    board_state.all_valid_moves(color).map do |move|
      duped_board = board_state.deep_dup_board
      duped_board.execute_move(move)
      duped_board
    end || [board_state]
  end

end

class ResetError < StandardError
end
