# frozen_string_literal: true

# Handles presentation.
class Screen
  COLORS = {
    -1 => "\e[48;5;228m\e[38;5;0m", # black on bright yellow
    2 => "\e[48;5;88m", # webmaroon
    4 => "\e[48;5;90m", # webpurple
    8 => "\e[48;5;72m", # seagreen
    16 => "\e[48;5;102m", # dimgray
    32 => "\e[48;5;55m", # indigo
    64 => "\e[48;5;105m", # mediumslateblue
    128 => "\e[48;5;106m", # olivedrab
    256 => "\e[48;5;109m", # cadetblue
    512 => "\e[48;5;202m", # orangered
    1024 => "\e[48;5;39m", # dodgerblue
    2048 => "\e[48;5;118m" # lawngreen
  }.freeze

  def initialize(board)
    @board = board
    print "\033[2J" # Clear screen.
    print "\033[?25l" # Hide cursor.
  end

  def finish
    print "\r\033[?25h" # Show cursor.
  end

  def draw(score)
    print "\033[0;0H" # Set cursor at top left.
    puts '+------' * @board.size + '+  ' + score.to_s
    @board.each { |row| draw_row(row) }
  end

  def draw_row(row)
    draw_line(row) { '' }
    draw_line(row) { |cell| cell&.abs }
    draw_line(row) { '' }
    puts "\r" + '+------' * @board.size + '+'
  end

  def draw_line(row)
    print "\r|"
    row.each { |cell| printf "%s%5s \e[0m|", color(cell), yield(cell) }
    puts
  end

  def color(value)
    return '' if value.nil?

    value > 0 ? COLORS[value] : COLORS[-1]
  end
end
