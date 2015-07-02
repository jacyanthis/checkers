class EmptySpace

  def to_s
    "   "
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

  def color
    :none
  end

end
