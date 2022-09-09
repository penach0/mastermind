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

  def show_possible_colors(line)
    keys = POSSIBLE_COLORS.keys
    values = POSSIBLE_COLORS.values

    case line
    when 1
      puts ' Possible colors:'
    when (3..POSSIBLE_COLORS.length + 2)
      puts " #{values[line - 3]} -> #{keys[line - 3].capitalize} "
    else
      puts ''
    end
  end

  def show_board
    line_template = '|. . | O  O  O  O | . .|'
    lines = []

    [*1..12].each do |line|
      puts '|######################|' if line == 12
      print line_template
      show_possible_colors(line)
      lines << [line_template]
    end
    puts ''

    lines
  end
end

class Sequence
  include UserChecks
  attr_reader :colors

  def initialize
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
  include UserChecks
  attr_accessor :board, :lines

  def initialize
    @lines = show_board
  end
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

game = Game.new

code = Code.new