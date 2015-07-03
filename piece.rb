require 'colorize'
require 'byebug'

class Piece
  attr_reader :board, :color
  attr_accessor :pos, :kinged

  def initialize(pos, board, color, kinged = false)
    @pos = pos
    @board = board
    @color = color
    @kinged = kinged
  end

  def to_s
    (kinged ? " ⛃ " : " ⛂ ").colorize(color)
  end

  def deep_dup(new_board)
    self.class.new(pos, new_board, color, kinged)
  end

  def edge?
    pos[0] == 0 || pos[0] == 7 || pos[1] == 0 || pos[1] == 7
  end

  def occupied?
    true
  end

  def empty?
    false
  end

  def move(new_pos)
    self.pos = new_pos
    maybe_king

    self
  end

  def maybe_king
    self.kinged = true if (pos[0] == 0 && color == :white) || (pos[0] == 7 && color == :red)
  end

  def can_jump?
    # puts "in can_jump?, my jumps are #{find_jumps}"
    !find_jumps.empty?
  end

  def moves
    find_slides + find_jumps
  end

  def find_slides
    if kinged
      find_slides_of_color(:red) + find_slides_of_color(:white)
    elsif color == :red
      find_slides_of_color(:red)
    elsif color == :white
      find_slides_of_color(:white)
    end
  end

  def find_slides_of_color(color)
    slide_positions(color).select do |slide|
      board.on_board?(slide) && !board.occupied?(slide)
    end
  end

  def slide_positions(color)
    if color == :red
      red_slide_positions
    elsif color == :white
      white_slide_positions
    end
  end

  def red_slide_positions
    [[pos[0] + 1, pos[1] + 1], [pos[0] + 1, pos[1] - 1]]
  end

  def white_slide_positions
    [[pos[0] - 1, pos[1] + 1], [pos[0] - 1, pos[1] - 1]]
  end

  def find_jumps
    if kinged
      find_jumps_of_color(:red) + find_jumps_of_color(:white)
    elsif color == :red
      find_jumps_of_color(:red)
    elsif color == :white
      find_jumps_of_color(:white)
    end
  end

  def find_jumps_of_color(jump_color)
    single_jumps(pos, jump_color).select do |jump|
      midpoint = find_midpoint(pos, jump)
      board.on_board?(jump) && board.enemy?(midpoint, color) && !board.occupied?(jump)
    end
  end

  def single_jumps(pos, jump_color)
    if jump_color == :red
      single_red_jumps(pos)
    elsif jump_color == :white
      single_white_jumps(pos)
    end
  end

  def single_red_jumps(start_pos)
    [[start_pos[0] + 2, start_pos[1] + 2], [start_pos[0] + 2, start_pos[1] - 2]]
  end

  def single_white_jumps(start_pos)
    [[start_pos[0] - 2, start_pos[1] + 2], [start_pos[0] - 2, start_pos[1] - 2]]
  end

  def find_midpoint(pos1, pos2)
    [(pos1[0] + pos2[0]) / 2, (pos1[1] + pos2[1]) / 2]
  end
end
