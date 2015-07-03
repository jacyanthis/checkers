require_relative 'piece'
require_relative 'emptyspace'


class Board
  attr_accessor :grid, :captured_pieces
  attr_reader :size, :army_rows, :game

  def initialize(game, size = 8, army_rows = 3)
    @game = game
    @size = size
    @army_rows = army_rows
    @sentinel = EmptySpace.new
    @grid = Array.new(8) { Array.new(8) { @sentinel } }
    @captured_pieces = []
    populate_board
  end

  def [](pos)
    row, col = pos
    @grid[row][col]
  end

  def []=(pos, new_piece)
    row, col = pos
    @grid[row][col] = new_piece
  end

  def populate_board
    army_rows.times do |row|
      populate_row(row, row.even?, :red)
      populate_row(size - 1 - row, row.odd?, :white)
    end
  end

  def populate_row(row, skip_first, color)
    size.times do |col|
      if skip_first && col.odd? || !skip_first && col.even?
        self[[row, col]] = Piece.new([row, col], self, color)
      end
    end
  end

  def execute_move(move)
    # puts "i am the board, executing the move: #{move}"
    start, finish = move
    is_jump = (start[0] - finish[0]).abs == 2

    # puts "i'm moving from #{start} to #{finish} and i am a #{self[start].class}"

    self[finish] = self[start].move(finish)
    self[start] = @sentinel

    # puts "now that i moved, i'm a #{self[finish].class}"

    if is_jump
      # puts "in the is_jump conditional, i am a #{self[finish].class} and my jumping ability is: #{self[finish].can_jump?}"
      destroy([(finish[0] + start[0]) / 2, (finish[1] + start[1]) / 2])
      requires_double_jump = self[finish].can_jump?
      if requires_double_jump
        # debugger
        # puts "in the requires_double_jump conditional, i am a #{self[finish].class} and my jumping ability is: #{self[finish].can_jump?}"
        new_jump = game.get_next_jump(self, finish)
        # puts "new landing is #{new_jump}"
        # puts "finish is #{finish}"
        # puts "i am in the requires_double_jump conditional"
        execute_move(new_jump)
      end
    end
  end

  def destroy(pos)
    captured_pieces << self[pos]
    self[pos] = @sentinel
  end

  def over?
    someone_won || tie
  end

  def someone_won
    @grid.flatten.none? { |piece| piece.color == :red } ||
      @grid.flatten.none? { |piece| piece.color == :white }
  end

  def tie
    all_valid_moves(:red).empty? || all_valid_moves(:white).empty?
  end

  def winner?
    if @grid.flatten.none? { |piece| piece.color == :red }
      :white
    elsif @grid.flatten.none? { |piece| piece.color == :white }
      :red
    else
      nil
    end
  end

  def valid?(pos)
    on_board?(pos) && !occupied?(pos)
  end

  def on_board?(pos)
    (0...8).include?(pos[0]) && (0...8).include?(pos[1])
  end

  def occupied?(pos)
    self[pos].occupied?
  end

  def enemy?(pos, color)
    self[pos].color == opposite_color(color)
  end

  def opposite_color(color)
    color == :red ? :white : :red
  end

  def deep_dup_board
    new_board = Board.new(game)
    new_grid = deep_dup_grid(grid, new_board)
    new_board.grid = new_grid
    new_board
  end

  def deep_dup_array(array, new_board)
    array.map do |piece|
      piece.deep_dup(new_board)
    end
  end

  def deep_dup_grid(array, new_board)
    return deep_dup_array(array, new_board) if array.none? {|el| el.is_a?(Array) }
    array.map {|el| deep_dup_grid(el, new_board)}
  end

  def all_valid_moves(color)
    all_pieces = grid.flatten.select do |piece|
      piece.color == color
    end

    all_pieces.map do |piece|
      piece.moves.map do |move|
        [piece.pos, move]
      end
    end.flatten(1)
  end

  def all_valid_jumps(pos)
    self[pos].find_jumps.map do |jump|
      [pos, jump]
    end
  end

  # def special_render
  #
  #     puts "    #{('A'..'H').to_a.join("  ")}"
  #
  #
  #     (0...8).each do |row_idx|
  #       print " #{row_idx + 1} "
  #       (0...8).each do |col_idx|
  #         if (row_idx + col_idx).even?
  #           print self[[row_idx, col_idx]].to_s.colorize(:background => :white)
  #         else
  #           print self[[row_idx, col_idx]].to_s.colorize(:background => :black)
  #         end
  #       end
  #       puts
  #     end
  # end
end
