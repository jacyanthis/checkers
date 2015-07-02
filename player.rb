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

  def get_next_jump(jump_pos)
    display.cursor_loop(:next_jump, jump_pos)
  end
end

class Computer < Player

end

class ResetError < StandardError
end
