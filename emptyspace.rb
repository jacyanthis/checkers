class EmptySpace

  def to_s
    "   "
  end

  def deep_dup(new_board)
    self
  end

  def occupied?
    false
  end

  def empty?
    true
  end

  def moves
    []
  end

  def find_jumps
    []
  end

  def color
    :none
  end

end
