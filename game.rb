require_relative 'display'
require_relative 'player'

class Game
  attr_accessor :board, :display, :players

  def self.pick_mode
    system 'clear'
    puts "Select your mode from the following:"
    puts "1 - Player vs. Player"
    puts "2 - Player vs. Computer"
    puts "3 - Computer vs. Computer"
    mode = gets.chomp
    case mode
    when "1"
      Game.new(:human, :human).run
    when "2"
      Game.new(:human, :computer).run
    when "3"
      Game.new(:computer, :computer).run
    end
  end

  def initialize(player1_sym, player2_sym)
    @board = Board.new(self)
    @display = Display.new(board, self)
    @players = [make_player(player1_sym, :black), make_player(player2_sym, :red)]
  end

  def make_player(player, color)
    player == :human ? Human.new(self, display, color) : Computer.new(self, display, color)
  end

  def current_player
    players.first
  end

  def current_color
    current_player.color
  end

  def run
    turn until game_over?
    game_over_message
  end

  def turn
    current_player.get_move
    switch_turn
  end

  def execute_move(move)
    board.execute_move(move)
  end

  def get_next_jump(jump_pos)
    current_player.get_next_jump(jump_pos)
  end

  def switch_turn
    players.rotate!
  end

  def game_over?
    board.over?
  end

  def game_over_message
    puts "Congratulations, #{board.winner}. You're the winner!"
  end

end

Game.new(:human, :human).run
