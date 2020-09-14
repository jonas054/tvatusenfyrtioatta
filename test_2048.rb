# frozen_string_literal: true

require 'test/unit'
require './main'

# Test the game
class Test2048 < Test::Unit::TestCase
  def setup
    srand 1
    setup_board
    $stdout = StringIO.new
  end

  def teardown
    $stdout = STDOUT
  end

  def test_setup_board
    assert_equal [[2, nil, nil, 4],
                  [nil, nil, nil, 4],
                  [nil, nil, nil, nil],
                  [nil, 2, nil, nil]], BOARD
  end

  def test_make_all_moves # rubocop:disable Metrics/MethodLength
    _ = nil # rubocop:disable Lint/UnderscorePrefixedVariableName
    check_board 'w', [[2, 2, _, 8],
                      [_, _, _, _],
                      [_, _, _, _],
                      [2, _, _, _]]
    check_board 'a', [[4, 8, _, _],
                      [_, _, 2, _],
                      [_, _, _, _],
                      [2, _, _, _]]
    check_board 'a', [[4, 8, _, _],
                      [2, _, 4, _],
                      [_, _, _, _],
                      [2, _, _, _]]
    check_board 'w', [[4, 8, 4, 4],
                      [4, _, _, _],
                      [_, _, _, _],
                      [_, _, _, _]]
    check_board 'd', [[_, 4, 8, 8],
                      [_, _, _, 4],
                      [_, 4, _, _],
                      [_, _, _, _]]
    check_board 'd', [[_, _, 4, 16],
                      [_, _, _,  4],
                      [_, _, _,  4],
                      [_, _, _,  4]]
    check_board 's', [[_, _, _,  _],
                      [_, _, _, 16],
                      [4, _, _,  4],
                      [_, _, 4,  8]]
    check_board 'd', [[_, _, _,  _],
                      [_, _, _, 16],
                      [_, _, _,  8],
                      [_, 4, 4,  8]]
    check_board 'd', [[_, _, _,  _],
                      [_, _, 2, 16],
                      [_, _, _,  8],
                      [_, _, 8,  8]]
    check_board 's', [[_, _, _,  _],
                      [4, _, _,  _],
                      [_, _, 2, 16],
                      [_, _, 8, 16]]
    check_board 's', [[_, _, _,  _],
                      [_, _, _,  _],
                      [_, _, 2,  _],
                      [4, 2, 8, 32]]
    check_board 'w', [[4, 2, 2, 32],
                      [_, _, 8,  _],
                      [_, _, _,  _],
                      [_, _, 2,  _]]
    check_board 'd', [[_, 4, 4, 32],
                      [_, 2, _,  8],
                      [_, _, _,  _],
                      [_, _, _,  2]]
    check_board 'a', [[8, 32, _, _],
                      [2,  8, _, _],
                      [_,  _, _, _],
                      [2,  4, _, _]]
    check_board 's', [[4,  _, _, _],
                      [_, 32, _, _],
                      [8,  8, _, _],
                      [4,  4, _, _]]
    check_board 'a', [[4, _, _, _],
                      [32, _, _, _],
                      [16, 2, _, _],
                      [8, _, _, _]]
    check_board 'w', [[4, 2, _, _],
                      [32, _, _, _],
                      [16, _, _, 4],
                      [8, _, _, _]]
    check_board 's', [[4, _, _, _],
                      [32, _, 4, _],
                      [16, _, _, _],
                      [8, 2, _, 4]]
    check_board 's', [[4, _, _, _],
                      [32, _, _, _],
                      [16, _, _, 2],
                      [8, 2, 4, 4]]
    check_board 'a', [[4, _, _, _],
                      [32, 2, _, _],
                      [16, 2, _, _],
                      [8, 2, 8, _]]
    check_board 'w', [[4, 4, 8, _],
                      [32, 2, _, _],
                      [16, _, 4, _],
                      [8, _, _, _]]
    check_board 'a', [[8, 8, _, _],
                      [32, 2, _, _],
                      [16, 4, _, _],
                      [8, _, _, 2]]
    check_board 'd', [[_, _, 4, 16],
                      [_, _, 32,  2],
                      [_, _, 16,  4],
                      [_, _, 8, 2]]
    check_board 'a', [[4, 16, _, _],
                      [32, 2, _, 2],
                      [16, 4, _, _],
                      [8, 2, _, _]]
    check_board 'a', [[4, 16, _, 4],
                      [32, 4, _, _],
                      [16, 4, _, _],
                      [8, 2, _, _]]
    check_board 'w', [[4, 16, _, 4],
                      [32, 8, _, _],
                      [16, 2, 2, _],
                      [8, _, _, _]]
    check_board 'a', [[4, 16, 4, _],
                      [32, 8, _, _],
                      [16, 4, _, _],
                      [8, 4, _, _]]
    check_board 's', [[4,   _, _, _],
                      [32, 16, _, 4],
                      [16,  8, _, _],
                      [8,   8, 4, _]]
    check_board 'a', [[4,   _, 4, _],
                      [32, 16, 4, _],
                      [16,  8, _, _],
                      [16,  4, _, _]]
    check_board 's', [[_,  _, _, 4],
                      [4, 16, _, _],
                      [32, 8, _, _],
                      [32, 4, 8, _]]
    check_board 's', [[ _,  4, _, _],
                      [ _, 16, _, _],
                      [ 4,  8, _, _],
                      [64,  4, 8, 4]]
  end

  def check_board(key, expected)
    make_all_moves(key)
    assert_equal expected, BOARD
  end

  def test_any_possible_moves?
    assert any_possible_moves?([[nil, 2, 64, 4],
                                [8, 128, 4, 8],
                                [32, 64, 8, 2],
                                [2, 4, 2, 16]])

    assert any_possible_moves?([[2, 2, 64, 4],
                                [8, 128, 4, 8],
                                [32, 64, 8, 2],
                                [2, 4, 2, 16]])

    assert_false any_possible_moves?([[4, 2, 64, 4],
                                      [8, 128, 4, 8],
                                      [32, 64, 8, 2],
                                      [2, 4, 2, 16]])
  end
end
