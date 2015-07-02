require 'colorize'
require 'byebug'

class Piece
  attr_reader :board, :color
  attr_accessor :pos, :kinged

  def initialize(pos, board, color)
    @pos = pos
    @board = board
    @color = color
    @kinged = false
  end

  def occupied?
    true
  end

  def empty?
    false
  end

  def move(new_pos)
    self.pos = new_pos
    update_kinged

    self
  end

  def update_kinged
    self.kinged = true if (pos[0] == 0 && color == :black) || (pos[0] == 7 && color == :red)
  end

  def can_jump?
    !find_jumps.empty?
  end

  def moves
    find_slides + find_jumps
  end

  def find_slides
    if kinged
      red_slides + black_slides
    elsif color == :red
      red_slides
    elsif color == :black
      black_slides
    end
  end

  def red_slides
    [[pos[0] + 1, pos[1] + 1], [pos[0] + 1, pos[1] - 1]].select do |slide|
      board.on_board?(slide) && !board.occupied?(slide)
    end
  end

  def black_slides
    [[pos[0] - 1, pos[1] + 1], [pos[0] - 1, pos[1] - 1]].select do |slide|
      board.on_board?(slide) && !board.occupied?(slide)
    end
  end

  def find_jumps
    if kinged
      find_jumps_of_color(:red) + find_jumps_of_color(:black)
    elsif color == :red
      find_jumps_of_color(:red)
    elsif color == :black
      find_jumps_of_color(:black)
    end
  end

  def find_jumps_of_color(color)
    single_jumps(pos, color).select do |jump|
      midpoint = find_midpoint(pos, jump)
      board.on_board?(jump) && board.enemy?(midpoint, color) && !board.occupied?(jump)
    end
  end

  def single_jumps(pos, color)
    if color == :red
      single_red_jumps(pos)
    elsif color == :black
      single_black_jumps(pos)
    end
  end


  def find_midpoint(pos1, pos2)
    [(pos1[0] + pos2[0]) / 2, (pos1[1] + pos2[1]) / 2]
  end


  def single_red_jumps(start_pos)
    [[start_pos[0] + 2, start_pos[1] + 2], [start_pos[0] + 2, start_pos[1] - 2]]
  end

  def single_black_jumps(start_pos)
    [[start_pos[0] - 2, start_pos[1] + 2], [start_pos[0] - 2, start_pos[1] - 2]]
  end

  def to_s
    (kinged ? " ⛃ " : " ⛂ ").colorize(color)
  end
end
