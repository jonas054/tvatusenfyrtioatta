# frozen_string_literal: true

require 'ostruct'
require 'test/unit'
require './main'

# Test the game
class TestMain < Test::Unit::TestCase
  def setup
    srand 1
    $stdout = StringIO.new
    @main = Main.new(4, 0, OpenStruct.new(play: nil))
  end

  def teardown
    $stdin = STDIN
    $stdout = STDOUT
  end

  def test_ctrl_c_immediately # rubocop:disable Metrics/MethodLength
    $stdin = StringIO.new("\u0003")
    @main.main
    assert_equal ["\e[2J\e[?25l\e[0;0H" \
                  '+------+------+------+------+  0',
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
                  '+------+------+------+------+',
                  "\e[?25h"]
      .join("\n\r")
      .gsub('!', "\e[0m|")
      .gsub('R', "\e[48;5;88m ")
      .gsub('P', "\e[48;5;90m "), $stdout.string
  end
end
