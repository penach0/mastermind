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
      puts if key == :blue
    end
    puts

    @colors = []
    while @colors.length < 4
      print 'Pick a color: '
      @colors << ask_colors
    end
  end
end

class Player

end

class Game

end

class Code < Sequence
  def initialize
    puts "************************\n"\
         "*****PICK YOUR CODE*****\n"\
         '************************'
    super
  end
end

class Guess < Sequence
  def initialize
    puts "*************************\n"\
         "*****PICK YOUR GUESS*****\n"\
         '*************************'
    super
  end
end


code = Code.new
puts code