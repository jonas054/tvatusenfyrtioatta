# frozen_string_literal: true

require 'ostruct'
require 'test/unit'
require './main'

# rubocop:disable Metrics/MethodLength

# Test the game
class TestMain < Test::Unit::TestCase
  def setup
    srand 1
    $stdout = StringIO.new
  end

  def teardown
    $stdin = STDIN
    $stdout = STDOUT
  end

  def _test_ctrl_c_immediately
    @main = Main.new(4, 0, OpenStruct.new(play: nil))
    $stdin = StringIO.new("\C-C")
    @main.main
    check_board ['+------+------+------+------+  0',
                 '|R     !      !      !P     !',
                 '|R  2  !      !      !P  4  !',
                 '|R     !      !      !P     !',
                 '+------+------+------+------+',
                 '|      !      !      !P     !',
                 '|      !      !      !P  4  !',
                 '|      !      !      !P     !',
                 '+------+------+------+------+',
                 '|      !      !      !      !',
                 '|      !      !      !      !',
                 '|      !      !      !      !',
                 '+------+------+------+------+',
                 '|      !R     !      !      !',
                 '|      !R  2  !      !      !',
                 '|      !R     !      !      !',
                 '+------+------+------+------+']
  end

  def test_size_3
    @main = Main.new(3, 0, OpenStruct.new(play: nil))
    $stdin = StringIO.new("\C-C")
    @main.main
    check_board ['+------+------+------+  0',
                 '|      !R     !      !',
                 '|      !R  2  !      !',
                 '|      !R     !      !',
                 '+------+------+------+',
                 '|R     !      !      !',
                 '|R  2  !      !      !',
                 '|R     !      !      !',
                 '+------+------+------+',
                 '|P     !P     !      !',
                 '|P  4  !P  4  !      !',
                 '|P     !P     !      !',
                 '+------+------+------+']
  end

  def test_size_2
    srand 5
    @main = Main.new(2, 0, OpenStruct.new(play: nil))
    Q << 's' << 'a' << 'w'
    @main.main
    check_board ['+------+------+  20',
                 '|R     !Q     !',
                 '|R  2  !Q  8  !',
                 '|R     !Q     !',
                 '+------+------+',
                 '|Q     !R     !',
                 '|Q  8  !R  2  !',
                 '|Q     !R     !',
                 '+------+------+']
  end

  def test_short_game
    @main = Main.new(4, 0, OpenStruct.new(play: nil))
    Q << 'w' << 'a' << "\C-C"
    @main.main
    check_board ['+------+------+------+------+  12',
                 '|P     !Q     !      !      !',
                 '|P  4  !Q  8  !      !      !',
                 '|P     !Q     !      !      !',
                 '+------+------+------+------+',
                 '|      !      !R     !      !',
                 '|      !      !R  2  !      !',
                 '|      !      !R     !      !',
                 '+------+------+------+------+',
                 '|      !      !      !      !',
                 '|      !      !      !      !',
                 '|      !      !      !      !',
                 '+------+------+------+------+',
                 '|R     !      !      !      !',
                 '|R  2  !      !      !      !',
                 '|R     !      !      !      !',
                 '+------+------+------+------+']
  end

  def check_board(expected)
    total = "\e[0;0H" + expected # rubocop:disable Style/StringConcatenation
            .join("\n\r")
            .gsub('!', "\e[0m|")
            .gsub('R', "\e[48;5;88m ")
            .gsub('Q', "\e[48;5;72m ")
            .gsub('P', "\e[48;5;90m ") + "\n\r\e[?25h"
    assert_equal total, $stdout.string[-total.length..-1]
  end
end

# rubocop:enable Metrics/MethodLength
