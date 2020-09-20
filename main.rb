# frozen_string_literal: true

require 'forwardable'
require 'gosu'
require './screen'
require './board'

Q = Queue.new

def read_keyboard
  loop do
    key = $stdin.getc
    2.times { key += $stdin.getc } if key == "\e" # Escape sequence.
    Q << key if Q.size < 1
  end
end

# Main 2048 class.
class Main
  attr_reader :board

  def initialize(size)
    @board = Board.new(size.to_i)
    @screen = Screen.new(@board)
    @score = 0
  end

  def main
    @sample = Gosu::Sample.new('Plopp3.ogg')
    @sleep_time = 0.2 / @board.size**3

    print "\033[2J" # Clear screen.
    print "\033[?25l" # Hide cursor.

    system('stty raw -echo')
    keyboard_reader = Thread.new { read_keyboard }

    loop do
      @screen.draw(@score)
      break unless @board.any_possible_moves?

      key = Q.pop
      break if key == "\u0003" # Ctrl-C

      make_all_moves(key)
    end
  ensure
    print "\r\033[?25h" # Show cursor.
    system('stty -raw echo')
    keyboard_reader.kill
  end

  def make_all_moves(key)
    before = @board.inspect
    last = @board.size - 1
    last.times do
      (0...last).each do |outer_ix|
        (0..last).each do |inner_ix|
          act_on_key(outer_ix, inner_ix, key, last)
          @screen.draw(@score)
          sleep(@sleep_time) if @sleep_time
        end
      end
    end

    @board.clean_up
    @board.add_at_random_pos(rand < 0.5 ? 2 : 4) if @board.inspect != before
  end

  def act_on_key(outer_ix, inner_ix, key, last)
    # rubocop:disable Layout/ExtraSpacing
    points = case key
             when 'w', "\e[A" then @board.move(inner_ix,        outer_ix,         0+1i)
             when 's', "\e[B" then @board.move(inner_ix,        last - outer_ix,  0-1i)
             when 'a', "\e[D" then @board.move(outer_ix,        inner_ix,         1+0i)
             when 'd', "\e[C" then @board.move(last - outer_ix, inner_ix,        -1+0i)
             end
    # rubocop:enable Layout/ExtraSpacing

    if points && points > 0
      @score += points
      @sample&.play
    end
  end
end

Main.new(ARGV.first || 4).main if $PROGRAM_NAME == __FILE__
