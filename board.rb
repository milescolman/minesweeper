require './tile.rb'
require 'byebug'
require 'colorize'
class Board

  attr_reader :grid, :cursor_position

  def initialize(dimensions = 9, bombs = 10)
    @grid = Array.new(dimensions) { Array.new(dimensions) }
    @cursor_position = [0, 0]
    populate_board(bombs)
    update_tile_neighbors
  end

  def [](row, col)
    @grid[row][col]
  end

  def []=(row, col, mark)
    @grid[row][col] = mark
  end

  def populate_board(bombs)
    bomb_positions = positions.sample(bombs)
    positions.each do |pos|
      if bomb_positions.include?(pos)
        self[*pos] = Tile.new(true)
      else
        self[*pos] = Tile.new(false)
      end
    end
  end

  def neighbors(pos)
    row, col = pos
    positions.select do |r_idx, c_idx|
      r_diff, c_diff = (r_idx - row).abs, (c_idx - col).abs
      [1, 2].include?(r_diff ** 2 + c_diff ** 2)
    end
  end

  def unrevealed_neighbors(pos)
    neighbors(pos).select { |pos| !self[*pos].revealed }
  end

  def neighbor_bomb_count(pos)
    bomb_count = 0
    neighbors(pos).each do |r_idx, c_idx|
      bomb_count += 1 if self[r_idx, c_idx].bomb
    end
    bomb_count
  end

  def update_tile_neighbors
    positions.each do |row, col|
      self[row, col].set_bomb_count(neighbor_bomb_count([row, col]))
    end
  end

  def positions
    positions = []
    length = grid.length
    (0...length).each{ |r| (0...length).each { |c| positions << [r, c] }}
    positions
  end

  def render(cursor = false)
    system('clear')
    letters = ('a'..'z').to_a
    puts '  '+ letters.take(grid.length).map(&:to_s).map(&:blue).join(' ')
    @grid.each_with_index do |row, row_idx|
      output_array = row.map.with_index do |tile, col_idx|
                       if @cursor_position == [row_idx, col_idx] && cursor
                         tile.to_s.colorize(:background => :blue)
                       else
                         tile.to_s
                       end
                     end
      puts "#{letters[row_idx].blue} #{output_array.join(" ")}"
    end
    puts "'r' for reveal, 'f' for flag" if cursor
    nil
  end

  def reveal(pos)
    #debugger
    if self[*pos].bomb || self[*pos].bomb_count > 0
      self[*pos].reveal
    else
      self[*pos].reveal
      unrevealed_neighbors(pos).each do |neighbor_pos|
        reveal(neighbor_pos)
      end
    end
    nil
  end

  def up_row
    row, col = @cursor_position.first, @cursor_position.last
    if row > 0
      @cursor_position = [row - 1, col]
    end
  end

  def down_row
    row, col = @cursor_position.first, @cursor_position.last
    if row < grid.length - 1
      @cursor_position = [row + 1, col]
    end
  end

  def right_col
    row, col = @cursor_position.first, @cursor_position.last
    if col < grid.length - 1
      @cursor_position = [row, col + 1]
    end
  end

  def left_col
    row, col = @cursor_position.first, @cursor_position.last
    if col > 0
      @cursor_position = [row, col - 1]
    end
  end
end
