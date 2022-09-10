module Input
  POSSIBLE_COLORS = { red: 'R', green: 'G', blue: 'B',
                      yellow: 'Y', white: 'W', purple: 'P' }.freeze
  KEYS = POSSIBLE_COLORS.keys
  VALUES = POSSIBLE_COLORS.values

  def check_colors(color)
    return color if POSSIBLE_COLORS.key?(color.downcase.to_sym)
    return color if POSSIBLE_COLORS.value?(color.upcase)

    puts 'That\'s not a valid color!'
    false
  end

  def ask_colors
    color = ''
    loop do
      puts 'Pick a color:'
      color = gets.chomp
      break if check_colors(color)
    end
    color[0].upcase
  end

  def pick_colors(pick_mode)
    colors = []
    if pick_mode == 'human'
      colors << ask_colors while colors.length < 4
    else
      colors << VALUES.sample while colors.length < 4
    end
    colors
  end

  def check_values(value, condition)
    return value if condition

    puts 'That\'s not a valid option'
    false
  end

  def ask_type
    type = ''
    loop do
      puts 'Play vs Human or Computer?'
      type = gets.chomp
      break if check_values(type, %w[human computer].include?(type.downcase))
    end
    type
  end

  def ask_role
    role = ''
    loop do
      puts 'Play as Codemaker or Codebreaker?'
      role = gets.chomp
      break if check_values(role, %w[codemaker codebreaker].include?(role.downcase))
    end
    role
  end
end

module Output
  POSSIBLE_COLORS = { red: 'R', green: 'G', blue: 'B',
                      yellow: 'Y', white: 'W', purple: 'P' }.freeze
  KEYS = POSSIBLE_COLORS.keys
  VALUES = POSSIBLE_COLORS.values

  def show_possible_colors(line)
    case line
    when 1
      puts ' Possible colors:'
    when (3..POSSIBLE_COLORS.length + 2)
      puts " #{VALUES[line - 3]} -> #{KEYS[line - 3].capitalize} "
    else
      puts ''
    end
  end

  def show_board(lines=[])
    line_template = '|. . | O  O  O  O | . .|'

    [*1..12].each do |line|
      puts '|######################|' if line == 12
      print line_template
      show_possible_colors(line)
      lines << line_template
    end
    puts ''

    lines
  end
end

class Game
  include Input
  include Output
  attr_accessor :board, :lines, :maker, :breaker

  def initialize
    @lines = show_board
  end

  def create_players
    opponent = ask_type
    player =
      opponent == 'computer' ? 'human' : ask_type
    role = ask_role
    if role == 'codemaker'
      @maker = CodeMaker.new(player)
      @breaker = CodeBreaker.new(opponent)
    else
      @maker = CodeMaker.new(opponent)
      @breaker = CodeBreaker.new(player)
    end
  end

  def set_code
    maker.create_code
    lines.last.gsub!('O', '$')
    show_board
  end
end

class Player
  include Input
  MAX_PLAYERS = 2
  attr_reader :type

  def initialize(type)
    @type = type
  end
end

class CodeMaker < Player
  def initialize(type)
    super
  end

  def create_code
    @code = Code.new(type)
  end
end

class CodeBreaker < Player
  def initialize(type)
    super
  end
end

class Sequence
  include Input
  include Output
  attr_reader :colors

  def initialize(player_type)
    @colors = pick_colors(player_type)
    pp @colors
  end
end

class Code < Sequence
  def initialize(player_type)
    if player_type == 'human'
      puts "************************\n"\
           "*****PICK YOUR CODE*****\n"\
           '************************'
    super(player_type)
    end
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
game.create_players
game.set_code
