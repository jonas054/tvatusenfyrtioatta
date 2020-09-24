# frozen_string_literal: true

# Implements the board with its squares and numbers, but not the representation
# in terms of colors and lines.
class Board
  extend Forwardable

  def_delegators :@squares, :size, :to_a, :each

  def initialize(size)
    @squares = Array.new(size) { Array.new(size) }
    [2, 2, 4, 4].each { |value| add_at_random_pos(value) }
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

  def move(x_pos, y_pos, delta)
    current = Complex(x_pos, y_pos)
    other = current + delta
    if self[current].nil?
      self[current] = self[other]
      self[other] = nil
    elsif self[current] == self[other] && self[current] > 0
      self[current] *= -2
      self[other] = nil
      return -self[current]
    end
    0
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
    each { |row| row.each_index { |c| row[c] = row[c].abs if row[c] } }
  end

  def any_possible_moves?(squares = @squares)
    !squares.flatten.all? ||
      [squares, squares.transpose].any? { |s| any_adjacent_equal?(s) }
  end

  def any_adjacent_equal?(squares)
    squares.any? { |row| row.each_cons(2).any? { |a, b| a == b } }
  end
end
