# frozen_string_literal: true

require 'gosu'
require './screen'

SIZE = 4
BOARD = Array.new(SIZE) { Array.new(SIZE) }

# Main 2048 class.
class Main
  def initialize
    @screen = Screen.new(BOARD)
  end

  def main
    @sample = Gosu::Sample.new('Plopp3.ogg')
    @sleep_time = 0.2 / SIZE ** 3

    print "\033[2J" # Clear screen.
    print "\033[?25l" # Hide cursor.
    setup_board

    system('stty raw -echo')
    @q = Queue.new
    keyboard_reader = Thread.new do
      loop do
        key = $stdin.getc
        2.times { key += $stdin.getc } if key == "\e" # Escape sequence.
        @q << key if @q.size < 2
      end
    end

    loop do
      @screen.draw(@score)
      break unless any_possible_moves?(BOARD)

      key = @q.pop
      make_all_moves(key)
      break if key == "\u0003" # Ctrl-C
    end
  ensure
    system('stty -raw echo')
    keyboard_reader.kill
  end

  def setup_board
    @score = 0
    BOARD.each { |row| row.each_index { |c| row[c] = nil } }
    [2, 2, 4, 4].each { |value| add_at_random_pos(value) }
  end

  def add_at_random_pos(value)
    pos = nil
    loop do
      pos = [rand(SIZE), rand(SIZE)]
      break if BOARD[pos.last][pos.first].nil?
    end
    BOARD[pos.last][pos.first] = value
  end

  def make_all_moves(key)
    @changed = false
    (SIZE - 1).times do
      (0...(SIZE - 1)).each do |a|
        (0...SIZE).each do |b|
          act_on_key(a, b, key)
          @screen.draw(@score)
          sleep @sleep_time if @sleep_time
        end
      end
    end

    return unless @changed

    clean_up
    add_at_random_pos(rand < 0.5 ? 2 : 4)
  end

  def act_on_key(a, b, key)
    case key
    when 'w', "\e[A" then move(b, a, [1, 0])
    when 's', "\e[B" then move(b, SIZE - 1 - a, [-1, 0])
    when 'a', "\e[D" then move(a, b, [0, 1])
    when 'd', "\e[C" then move(SIZE - 1 - a, b, [0, -1])
    end
  end

  def move(x, y, dir)
    x1 = x + dir.last
    y1 = y + dir.first
    if BOARD[y][x].nil?
      @changed = true if BOARD[y1][x1]
      BOARD[y][x] = BOARD[y1][x1]
      BOARD[y1][x1] = nil
    elsif BOARD[y][x] == BOARD[y1][x1] && BOARD[y][x] > 0
      @sample&.play
      BOARD[y][x] *= -2
      BOARD[y1][x1] = nil
      @changed = true
      @score -= BOARD[y][x]
    end
  end

  def clean_up
    BOARD.each { |row| row.each_index { |c| row[c] = row[c].abs if row[c] } }
  end

  def any_possible_moves?(board)
    return true if board.flatten.compact.size < SIZE * SIZE
    return true if any_adjacent_equal?(board)

    any_adjacent_equal?(board.transpose)
  end

  def any_adjacent_equal?(board)
    board.any? { |row| row.each_cons(2).any? { |a, b| a == b } }
  end
end

Main.new.main if $PROGRAM_NAME == __FILE__
