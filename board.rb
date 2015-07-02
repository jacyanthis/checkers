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
      populate_row(size - 1 - row, row.odd?, :black)
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
    start, finish = move
    is_jump = (start[0] - finish[0]).abs == 2

    self[finish] = self[start].move(finish)
    self[start] = @sentinel

    if is_jump
      requires_double_jump = self[finish].can_jump?
      destroy([(finish[0] + start[0]) / 2, (finish[1] + start[1]) / 2])
      if requires_double_jump
        new_landing = game.get_next_jump(finish)
        puts "new landing is #{new_landing}"
        puts "finish is #{finish}"
        execute_move([finish, new_landing])
      end
    end
  end

  def destroy(pos)
    captured_pieces << self[pos]
    self[pos] = @sentinel
  end

  def over?
    @grid.flatten.none? { |piece| piece.color == :red } ||
    @grid.flatten.none? { |piece| piece.color == :black }
  end

  def winner?
    if @grid.flatten.none? { |piece| piece.color == :red }
      :black
    else
      :red
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
    color == :red ? :black : :red
  end
end
