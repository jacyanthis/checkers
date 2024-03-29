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
  attr_accessor :next_jump, :intelligence, :special_sauce

  def initialize(game, display, color, intelligence, special_sauce)
    super(game, display, color)
    @next_jump = nil
    @intelligence = intelligence #0-4 (gets slowed as intelligence increases)
    @special_sauce = special_sauce #uses an improved heuristic for valuing the board
  end

  def get_next_jump(duped_board, jump_pos)
    duped_board.all_valid_jumps(jump_pos).max_by do |move|
      new_duped_board = duped_board.deep_dup_board
      new_duped_board.execute_move(move)
      move_value = direct_value(duped_board)
      move_value
    end
  end

  def get_move
    moves_with_values = game.board.all_valid_moves(color).map do |move|
      duped_board = game.board.deep_dup_board
      duped_board.execute_move(move)
      move_value = find_value(duped_board, :opponent, intelligence)
      [move, move_value]
    end

    best_move_with_value = moves_with_values.max_by { |move, value| value }

    best_pairs = moves_with_values.select { |move, value| value == best_move_with_value[1]}

    best_moves = best_pairs.map { |move, value| move }
    game.execute_move(best_moves.sample)
    display.render
  end

  def find_value(board_state, player, depth)
    return direct_value(board_state) if depth == 0
    if player == :self
      values = potential_board_states(board_state, color).map do |state|
        find_value(state, :opponent, depth - 1)
      end
      values.empty? ? find_value(board_state, :opponent, depth - 1) : values.max
    else
      values = potential_board_states(board_state, game.board.opposite_color(color)).map do |state|
        find_value(state, :self, 0)
      end
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

    num_self_kings = board_state.grid.flatten.select do |piece|
      piece.kinged == true && piece.color == color
    end.count

    num_enemy_kings = board_state.grid.flatten.select do |piece|
      piece.kinged == true && piece.color == board_state.opposite_color(color)
    end.count

    num_self_edge = board_state.grid.flatten.select do |piece|
      piece.edge? == true && piece.color == color
    end.count

    num_enemy_edge = board_state.grid.flatten.select do |piece|
      piece.edge? == true && piece.color == board_state.opposite_color(color)
    end.count

    if special_sauce
      num_self_pieces - num_enemy_pieces + (2 * num_self_kings) - (2 * num_enemy_kings) + (1.5 * num_self_edge) - (1.5 * num_enemy_edge)
    else
      num_self_pieces - num_enemy_pieces
    end
  end

  def potential_board_states(board_state, color)
    board_state.all_valid_moves(color).map do |move|
      duped_board = board_state.deep_dup_board
      duped_board.execute_move(move)
      duped_board
    end
  end

end

class ResetError < StandardError
end
