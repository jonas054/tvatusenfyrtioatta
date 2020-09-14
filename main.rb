# frozen_string_literal: true

require 'gosu'

COLORS = {
  -1 => "\e[48;5;46m", # lime
  2 => "\e[48;5;88m", # webmaroon
  4 => "\e[48;5;90m", # webpurple
  8 => "\e[48;5;72m", # seagreen
  16 => "\e[48;5;102m", # dimgray
  32 => "\e[48;5;55m", # indigo
  64 => "\e[48;5;105m", # mediumslateblue
  128 => "\e[48;5;106m", # olivedrab
  256 => "\e[48;5;109m", # cadetblue
  512 => "\e[48;5;111m", # cornflower
  1024 => "\e[48;5;39m", # dodgerblue
  2048 => "\e[48;5;118m" # lawngreen
}.freeze

SIZE = 4
BOARD = Array.new(SIZE) { Array.new(SIZE) }

def main
  @sample = Gosu::Sample.new('Plopp3.ogg')
  @sleep_time = 0.01

  printf("\033[2J"); # Clear screen.
  printf("\033[?25l"); # Hide cursor.
  setup_board

  loop do
    draw
    break unless any_possible_moves?(BOARD)

    key = read_keyboard
    2.times { key += read_keyboard } if key == "\e" # Escape sequence.
    make_all_moves(key)
    break if key == "\u0003" # Ctrl-C
  end
ensure
  printf("\033[?25h"); # Show cursor.
end

def setup_board
  @score = 0
  BOARD.each do |row|
    row.each_index { |c| row[c] = nil }
  end
  2.times { add_at_random_pos(2) }
  2.times { add_at_random_pos(4) }
end

def add_at_random_pos(value)
  pos = nil
  loop do
    pos = [rand(SIZE), rand(SIZE)]
    break if BOARD[pos.last][pos.first].nil?
  end
  BOARD[pos.last][pos.first] = value
end

def draw
  printf("\033[0;0H"); # Set cursor at top left.
  puts '+-----' * SIZE + '+  ' + @score.to_s
  BOARD.each do |row|
    draw_row(row)
  end
end

def draw_row(row)
  print '|'
  row.each { |cell| printf "%s     \e[0m|", color(cell) }
  print "\n|"
  row.each { |cell| printf "%s%4s \e[0m|", color(cell), cell&.abs }
  print "\n|"
  row.each { |cell| printf "%s     \e[0m|", color(cell) }
  puts
  puts '+-----' * SIZE + '+'
end

def color(value)
  return '' if value.nil?

  value > 0 ? COLORS[value] : COLORS[-1]
end

def read_keyboard
  system('stty raw -echo')
  $stdin.getc
ensure
  system('stty -raw echo')
end

def make_all_moves(key)
  @changed = false
  (SIZE - 1).times do
    (0...(SIZE - 1)).each do |a|
      (0...SIZE).each do |b|
        act_on_key(a, b, key)
        draw
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
  elsif BOARD[y][x] == BOARD[y1][x1] && BOARD[y][x].positive?
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

main if $PROGRAM_NAME == __FILE__
