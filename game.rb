require './board.rb'
require './tile.rb'
require 'yaml'

class Minesweeper

  def initialize(dimensions = 9, bombs = 10, savefile = nil)
    if savefile
      @board = YAML::load(File.read(savefile))
    else
      @board = Board.new(dimensions, bombs)
    end
  end

  def play
    action = nil
    until lost? || won? || action == 'q'
      system('clear')
      @board.render(true)
      if action = prompt
        action == 'q' ? prompt_for_save : update_board(action)
      end
    end
    system('clear')
    @board.render
    puts won? ? "Congratulations!" : "You lose!" unless action == 'q'
  end

  def lost?
    @board.positions.any? do |pos|
      @board[*pos].bomb && @board[*pos].revealed
    end
  end

  def won?
    @board.positions.none? do |pos|
      tile = @board[*pos]
      !tile.bomb && !tile.revealed
    end
  end

  def prompt_for_save
    print "Press 's' for save: "
    if gets.chomp == 's'
      puts "Enter filename:"
      File.open(gets.chomp,'w') do |f|
       f.puts(@board.to_yaml)
     end
   end
 end

  def prompt
    @board.render(true)
    action = $stdin.getch
    case action
    when 'w'
      @board.up_row
      nil
    when 's'
      @board.down_row
      nil
    when 'a'
      @board.left_col
      nil
    when 'd'
      @board.right_col
      nil
    when 'f'
      return 'f'
    when 'r'
      return ''
    when 'q'
      return 'q'
    end
  end


  def update_board(action)
    pos = @board.cursor_position
    if action == "f"
      @board[*pos].flagged ? @board[*pos].unflag : @board[*pos].flag
    else
      @board.reveal(pos)
    end
  end

  def inspect
    nil
  end

end

if __FILE__ == $0
  game = Minesweeper.new
  game.play
end
