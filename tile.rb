require 'colorize'
class Tile

  attr_reader :bomb, :revealed, :flagged, :bomb_count

  def initialize(bomb_flag)
    @bomb = bomb_flag
    @revealed = false
    @flagged = false
    @cheat = true
  end

  def reveal
    unless flagged
      @revealed = true
    end
  end

  def flag
    @flagged = true
  end

  def unflag
    @flagged = false
  end

  def set_bomb_count(count)
    @bomb_count = count
  end

  def to_s
    if flagged
      'F'
    elsif @cheat && bomb
      'B'.colorize(:red)
    elsif revealed
      bomb ? 'B' : ( (bomb_count == 0) ? '_' : color_bomb_to_s )
    else
      '*'
    end
  end

  def color_bomb_to_s
    bombs = bomb_count.to_s
    if bomb_count == 1
      bombs
    elsif bomb_count == 2
      bombs.colorize(:yellow)
    else
      bombs.colorize(:red)
    end
  end

end
