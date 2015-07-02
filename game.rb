require_relative 'display'
require_relative 'player'
require 'yaml'

class Game
  attr_accessor :board, :display, :players

  def self.load_file
    puts "Which file would you like to load?"
    filename = gets.chomp
    loaded_game = File.open(filename, "r") { |f| YAML::load(f) }
    loaded_game.run
  end

  def initialize
    @board = Board.new(self)
    @display = Display.new(board, self)
    @players = pick_mode
    run
  end

  def pick_mode
    display.display_modes
    mode = gets.chomp
    case mode
    when "1"
      [Human.new(self, display, :white), Human.new(self, display, :red)]
    when "2"
      [Human.new(self, display, :white), Computer.new(self, display, :red, 2)]
    when "3"
      [Computer.new(self, display, :white, 0), Computer.new(self, display, :red, 2)]
    when "4"
      Game.load_file
    end
  end

  def save
    puts "What filename would you like to use for this save?"
    filename = gets.chomp
    File.open(filename, "w") { |f| f.write(self.to_yaml) }
  end

  def current_player
    players.first
  end

  def current_color
    current_player.color
  end

  def run
    turn until game_over?
    display.game_over_message
  end

  def turn
    current_player.get_move
    switch_turn
  end

  def execute_move(move)
    board.execute_move(move)
  end

  def get_next_jump(duped_board, jump_pos)
    current_player.get_next_jump(duped_board, jump_pos)
  end

  def switch_turn
    players.rotate!
  end

  def game_over?
    board.over?
  end
end

Game.new
