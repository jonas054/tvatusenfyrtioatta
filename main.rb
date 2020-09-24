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
    Q << key if Q.empty?
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

    system('stty raw -echo')
    keyboard_reader = Thread.new { read_keyboard }

    loop do
      @screen.draw(@score)
      break unless @board.any_possible_moves?

      key = Q.pop
      break if key == "\u0003" # Ctrl-C

      @board.make_all_moves(key) do |points|
        if points > 0
          @score += points
          @sample.play
        end
        @screen.draw(@score)
        sleep(@sleep_time) if @sleep_time
      end
    end
  ensure
    @screen.finish
    system('stty -raw echo')
    keyboard_reader.kill
  end
end

Main.new(ARGV.first || 4).main if $PROGRAM_NAME == __FILE__
