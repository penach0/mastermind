module UserChecks
  POSSIBLE_COLORS = { red: 'R', green: 'G', blue: 'B',
                      yellow: 'Y', white: 'W', purple: 'P' }.freeze

  def check_colors(color)
    return color if POSSIBLE_COLORS.key?(color.downcase.to_sym)
    return color if POSSIBLE_COLORS.value?(color.upcase)

    puts 'That\'s not a valid color!'
    false
  end

  def ask_colors
    color = ''
    loop do
      color = gets.chomp
      break if check_colors(color)
    end
    color[0].upcase
  end
end

class Sequence
  include UserChecks
  attr_reader :colors

  def initialize
    puts 'Possible colors:'
    POSSIBLE_COLORS.each do |key, value|
      print "| #{value} -> #{key.capitalize} "
    end

    @colors = []
    while @colors.length < 4
      puts "\nPick a color:"
      @colors << ask_colors
    end

    puts @colors.inspect
  end

end

class Player

end

class Game

end

class Code < Sequence

end

class Guess < Sequence

end

sequence = Sequence.new
