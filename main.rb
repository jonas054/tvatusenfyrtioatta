# frozen_string_literal: true

require 'forwardable'
require 'gosu'
require './screen'
require './board'

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
      break if key == "\u0003" # Ctrl-C

      make_all_moves(key)
    end
  end

  def make_all_moves(key)
    @board.make_all_moves(key) do |points|
      if points > 0
        @score += points
        @sample.play
      end
      @screen.draw(@score)
      sleep(@sleep_time)
    end
  end
end

if $PROGRAM_NAME == __FILE__
  Main.new(ARGV.first || 4, 0.2, Gosu::Sample.new('Plopp3.ogg')).main
end
