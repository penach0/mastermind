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
      ' Possible colors:'
    when (3..POSSIBLE_COLORS.length + 2)
      " #{VALUES[line - 3]} -> #{KEYS[line - 3].capitalize} "
    else
      ''
    end
  end

  def create_board
    line_template = '|. . | O  O  O  O | . .|'
    lines = []

    [*1..14].each do |line|
      current_line =  line == 13 ? '|######################|' : line_template + show_possible_colors(line)
      puts current_line
      lines << current_line
    end
    puts ''

    lines
  end

  def update_board(lines)
    lines.each do |line|
      puts line
    end
  end

  def sub_guesses(line, guess_array)
    guess_array.each do |color|
      line.sub!('O', color)
    end
    line
  end
end

class Game
  include Input
  include Output
  attr_accessor :board, :lines, :maker, :breaker

  def initialize
    @lines = create_board
  end

  def create_players
    player = ask_role
    opponent_type = ask_type
    if player == 'codemaker'
      @maker = CodeMaker.new('human')
      @breaker = CodeBreaker.new(opponent_type)
    else
      @maker = CodeMaker.new(opponent_type)
      @breaker = CodeBreaker.new('human')
    end
  end

  def set_code
    lines.last.gsub!('O', '$')
    update_board(lines)
  end

  def guessing
    i = 0
    while i < 12
      sub_guesses(lines[i], breaker.make_guess.colors)
      update_board(lines)
      i += 1
    end
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
    @code = Code.new(type)
  end
end

class CodeBreaker < Player
  attr_reader :type

  def initialize(type)
    super
  end

  def make_guess
    Guess.new(type)
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
    end
    super(player_type)
  end
end

class Guess < Sequence
  def initialize(player_type)
    if player_type == 'human'
    puts "*************************\n"\
         "*****PICK YOUR GUESS*****\n"\
         '*************************'
    end
    super(player_type)
  end
end

game = Game.new
game.create_players
game.set_code
game.guessing