class Board
  extend Forwardable

  def_delegators :@squares, :size, :[], :[]=, :to_a, :each
  
  def initialize(size)
    @squares = Array.new(size) { Array.new(size) }
    [2, 2, 4, 4].each { |value| add_at_random_pos(value) }
  end

  def add_at_random_pos(value)
    pos = nil
    loop do
      pos = [rand(size), rand(size)]
      break if self[pos.last][pos.first].nil?
    end
    self[pos.last][pos.first] = value
  end

  def clean_up
    each { |row| row.each_index { |c| row[c] = row[c].abs if row[c] } }
  end

  def any_possible_moves?(squares = @squares)
    return true if squares.flatten.compact.size < size**2

    any_adjacent_equal?(squares) || any_adjacent_equal?(squares.transpose)
  end

  def any_adjacent_equal?(squares)
    squares.any? { |row| row.each_cons(2).any? { |a, b| a == b } }
  end
end
