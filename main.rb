# frozen_string_literal: true

require 'forwardable'
require 'gosu'

# Handles presentation.
class Screen
  COLORS = {
    -1   => "\e[48;5;228m\e[38;5;0m", # black on bright yellow
    2    => "\e[48;5;88m",            # webmaroon
    4    => "\e[48;5;90m",            # webpurple
    8    => "\e[48;5;72m",            # seagreen
    16   => "\e[48;5;102m",           # dimgray
    32   => "\e[48;5;55m",            # indigo
    64   => "\e[48;5;105m",           # mediumslateblue
    128  => "\e[48;5;106m",           # olivedrab
    256  => "\e[48;5;109m",           # cadetblue
    512  => "\e[48;5;202m",           # orangered
    1024 => "\e[48;5;39m",            # dodgerblue
    2048 => "\e[48;5;118m"            # lawngreen
  }.freeze

  def initialize(board)
    @board = board
    print "\e[2J" # Clear screen.
    print "\e[?25l" # Hide cursor.
  end

  def finish
    print "\r\e[?25h" # Show cursor.
  end

  def draw(score)
    print "\e[0;0H" # Set cursor at top left.
    puts "#{'+------' * @board.size}+  #{score}"
    @board.each { |row| draw_row(row) }
  end

  def draw_row(row)
    draw_line(row) { '' }
    draw_line(row) { |cell| cell ? cell.abs.to_s.center(5) : '' }
    draw_line(row) { '' }
    puts "\r#{'+------' * @board.size}+"
  end

  def draw_line(row)
    print "\r|"
    row.each { |cell| printf "%s %5s\e[0m|", color(cell), yield(cell) }
    puts
  end

  def color(value)
    value ? COLORS[[value, -1].max] : ''
  end
end

# Implements the board with its squares and numbers, but not the representation
# in terms of colors and lines.
class Board
  extend Forwardable

  def_delegators :@squares, :size, :to_a, :each

  def initialize(size)
    @squares = Array.new(size) { Array.new(size) }
    [2, 2, 4, 4].each { |value| add_at_random_pos(value) }
  end

  def make_all_moves(key)
    before = inspect
    last = size - 1
    last.times do
      Array(0...last).product(Array(0..last)) do |outer_ix, inner_ix|
        yield move_for_key(outer_ix, inner_ix, key) || 0
      end
    end

    clean_up
    add_at_random_pos(rand < 0.5 ? 2 : 4) if inspect != before
  end

  def move_for_key(outer_ix, inner_ix, key)
    last = size - 1
    # rubocop:disable Layout/ExtraSpacing
    case key
    when 'w', "\e[A" then move(inner_ix,        outer_ix,        0 + 1i)
    when 's', "\e[B" then move(inner_ix,        last - outer_ix, 0 - 1i)
    when 'a', "\e[D" then move(outer_ix,        inner_ix,        1 + 0i)
    when 'd', "\e[C" then move(last - outer_ix, inner_ix,       -1 + 0i)
    end
    # rubocop:enable Layout/ExtraSpacing
  end

  # Makes the move and returns the number of points for it.
  def move(x_pos, y_pos, delta)
    current = Complex(x_pos, y_pos)
    other = current + delta
    if self[current].nil?
      self[current] = self[other]
      self[other] = nil
    elsif self[current] == self[other]
      self[current] *= -2
      self[other] = nil
      -self[current]
    end
  end

  def [](complex)
    @squares[complex.imag][complex.real]
  end

  def []=(complex, value)
    @squares[complex.imag][complex.real] = value
  end

  def add_at_random_pos(value)
    while true
      pos = Complex(rand(size), rand(size))
      break if self[pos].nil?
    end

    self[pos] = value
  end

  def clean_up
    each { |row| row.each_index { |c| row[c] = row[c]&.abs } }
  end

  def any_possible_moves?(squares = @squares)
    !squares.flatten.all? ||
      [squares, squares.transpose].any? { |s| any_adjacent_equal?(s) }
  end

  def any_adjacent_equal?(squares)
    squares.any? { |row| row.each_cons(2).any? { |a, b| a == b } }
  end
end

Q = Queue.new

# Main 2048 class.
class Main
  attr_reader :board

  def initialize(size, sleep_time, sample)
    @board = Board.new(size.to_i)
    @screen = Screen.new(@board)
    @score = 0
    @sample = sample
    @sleep_time = sleep_time / @board.size**3
  end

  def main
    system('stty raw -echo')
    keyboard_reader = Thread.new { read_keyboard }

    main_loop
  ensure
    @screen.finish
    system('stty -raw echo')
    keyboard_reader.kill
  end

  def read_keyboard
    loop do
      key = $stdin.getc
      2.times { key += $stdin.getc } if key == "\e" # Escape sequence.
      Q << key if Q.empty?
    end
  end

  def main_loop
    loop do
      @screen.draw(@score)
      break unless @board.any_possible_moves?

      key = Q.pop
      break if key == "\C-C"

      make_all_moves(key)
    end
  end

  def make_all_moves(key)
    @board.make_all_moves(key) do |points|
      @sample.play if points > 0
      @screen.draw(@score += points)
      sleep(@sleep_time)
    end
  end
end

if $PROGRAM_NAME == __FILE__
  Main.new(ARGV.first || 4, 0.2, Gosu::Sample.new('Plopp3.ogg')).main
end
