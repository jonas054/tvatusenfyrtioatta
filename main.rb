# frozen_string_literal: true

require 'gosu'
require './screen'

# Main 2048 class.
class Main
  attr_reader :board

  def initialize(size)
    @board = Array.new(size.to_i) { Array.new(size.to_i) }
    [2, 2, 4, 4].each { |value| add_at_random_pos(value) }
    @screen = Screen.new(@board)
    @score = 0
  end

  def main
    @sample = Gosu::Sample.new('Plopp3.ogg')
    @sleep_time = 0.2 / @board.size**3

    print "\033[2J" # Clear screen.
    print "\033[?25l" # Hide cursor.

    system('stty raw -echo')
    @q = Queue.new
    keyboard_reader = Thread.new do
      loop do
        key = $stdin.getc
        2.times { key += $stdin.getc } if key == "\e" # Escape sequence.
        @q << key if @q.size < 1
      end
    end

    loop do
      @screen.draw(@score)
      break unless any_possible_moves?(@board)

      key = @q.pop
      break if key == "\u0003" # Ctrl-C

      make_all_moves(key)
    end
  ensure
    print "\r\033[?25h" # Show cursor.
    system('stty -raw echo')
    keyboard_reader.kill
  end

  def add_at_random_pos(value)
    pos = nil
    loop do
      pos = [rand(@board.size), rand(@board.size)]
      break if @board[pos.last][pos.first].nil?
    end
    @board[pos.last][pos.first] = value
  end

  def make_all_moves(key)
    @changed = false
    size = @board.size
    (size - 1).times do
      (0...(size - 1)).each do |outer_ix|
        (0...size).each do |inner_ix|
          act_on_key(outer_ix, inner_ix, key)
          @screen.draw(@score)
          sleep @sleep_time if @sleep_time
        end
      end
    end

    clean_up
    add_at_random_pos(rand < 0.5 ? 2 : 4) if @changed
  end

  def act_on_key(outer_ix, inner_ix, key)
    size = @board.size
    # rubocop:disable Layout/ExtraSpacing
    case key
    when 'w', "\e[A" then move(inner_ix,            outer_ix,             0,  1)
    when 's', "\e[B" then move(inner_ix,            size - 1 - outer_ix,  0, -1)
    when 'a', "\e[D" then move(outer_ix,            inner_ix,             1,  0)
    when 'd', "\e[C" then move(size - 1 - outer_ix, inner_ix,            -1,  0)
    end
    # rubocop:enable Layout/ExtraSpacing
  end

  def move(x, y, dx, dy)
    x1 = x + dx
    y1 = y + dy
    if @board[y][x].nil?
      @changed = true if @board[y1][x1]
      @board[y][x] = @board[y1][x1]
      @board[y1][x1] = nil
    elsif @board[y][x] == @board[y1][x1] && @board[y][x] > 0
      @sample&.play
      @score += 2 * @board[y][x]
      @board[y][x] *= -2
      @board[y1][x1] = nil
      @changed = true
    end
  end

  def clean_up
    @board.each { |row| row.each_index { |c| row[c] = row[c].abs if row[c] } }
  end

  def any_possible_moves?(board)
    return true if board.flatten.compact.size < @board.size**2

    any_adjacent_equal?(board) || any_adjacent_equal?(board.transpose)
  end

  def any_adjacent_equal?(board)
    board.any? { |row| row.each_cons(2).any? { |a, b| a == b } }
  end
end

Main.new(ARGV.first || 4).main if $PROGRAM_NAME == __FILE__
