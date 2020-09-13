# frozen_string_literal: true

COLORS = {
  1 => "\e[48;5;86m", # turquoise
  2 => "\e[48;5;88m", # webmaroon
  4 => "\e[48;5;90m", # webpurple
  8 => "\e[48;5;72m", # seagreen
  16 => "\e[48;5;102m", # dimgray
  32 => "\e[48;5;55m", # indigo
  64 => "\e[48;5;105m", # mediumslateblue
  128 => "\e[48;5;106m", # olivedrab
  256 => "\e[48;5;109m", # cadetblue
  512 => "\e[48;5;111m", # cornflower
  1024 => "\e[48;5;115m", # mediumaquamarine
  2048 => "\e[48;5;118m" # lawngreen
}.freeze

SIZE = 4
BOARD = Array.new(SIZE) { Array.new(SIZE) }

def main
  printf("\033[2J"); # Clear screen.
  @score = 0
  setup_board

  loop do
    draw
    break unless any_possible_moves?(BOARD)

    key = read_keyboard
    if key == "\e"
      read_keyboard
      key = read_keyboard
    end
    make_all_moves(key)
    break if key == "\u0003" # Ctrl-C
  end
end

def setup_board
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
  row.each { |cell| printf "%s     \e[0m|", COLORS[cell] }
  print "\n|"
  row.each { |cell| printf "%s%4s \e[0m|", COLORS[cell], cell }
  print "\n|"
  row.each { |cell| printf "%s     \e[0m|", COLORS[cell] }
  puts
  puts '+-----' * SIZE + '+'
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
      end
    end
  end

  return unless @changed

  clean_up
  add_at_random_pos(rand < 0.5 ? 2 : 4)
end

def act_on_key(a, b, key)
  case key
  when 'w', 'A' then move(b, a, [1, 0])
  when 's', 'B' then move(b, SIZE - 1 - a, [-1, 0])
  when 'a', 'D' then move(a, b, [0, 1])
  when 'd', 'C' then move(SIZE - 1 - a, b, [0, -1])
  end
end

def move(x, y, dir)
  x1 = x + dir.last
  y1 = y + dir.first
  case BOARD[y][x]
  when nil
    @changed = true if BOARD[y1][x1]
    BOARD[y][x] = BOARD[y1][x1]
    BOARD[y1][x1] = nil
  when BOARD[y1][x1]
    if BOARD[y][x].positive?
      BOARD[y][x] *= -2
      BOARD[y1][x1] = nil
      @changed = true
      @score -= BOARD[y][x]
    end
  end
end

def clean_up
  BOARD.each { |row| row.each_index { |c| row[c] = row[c].abs if row[c] } }
end

def any_possible_moves?(board)
  return true if board.flatten.compact.size < SIZE * SIZE
  return true if board.any? { |row| any_adjacent_equal?(row) }

  board.transpose.any? { |row| any_adjacent_equal?(row) }
end

def any_adjacent_equal?(row)
  row.each_cons(2).any? { |a, b| a == b }
end

main if $PROGRAM_NAME == __FILE__
