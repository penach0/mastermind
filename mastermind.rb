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

  def show_info(line)
    case line
    when 1
      ' Possible colors:'
    when (3..8)
      " #{VALUES[line - 3]} -> #{KEYS[line - 3].capitalize} "
    when 10
      ' Feedback:'
    when 11
      ' = -> Correct in both color and position'
    when 12
      ' + -> Correct in color but wrong position'
    else
      ''
    end
  end

  def create_board
    line_template = '|. . | O  O  O  O | . .|'
    lines = []

    [*1..14].each do |line|
      current_line =  line == 13 ? '|######################|' : line_template + show_info(line)
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
    puts ''
  end

  def sub_lines(line, colors_array)
    colors_array.each do |color|
      line.sub!(/O|\$/, color)
    end
    line
  end

  def array_comparison(code, guess, i)
    return '=' if code[i] == guess[i]

    return '+' if code[i] != guess[i] && code.include?(guess[i])
  end

  def count_ocurrences(array)
    array.reduce({}) do |hash, item|
      hash[item] ||= 0
      hash[item] += 1
      hash
    end
  end

  def compare_hash(hash1, hash2)
    extra_plus = 0
    hash1.each do |key1, value1|
      hash2.each do |key2, value2|
        next unless key2 == key1

        extra_plus = value2 - value1 if value2 > value1
      end
    end
    extra_plus
  end

  def sub_feedback(line, feedback_array)
    feedback_array.shuffle.each do |feedback|
      line.sub!('.', feedback)
    end
    line
  end
end

module Computer
  POSSIBLE_COLORS = { red: 'R', green: 'G', blue: 'B',
                      yellow: 'Y', white: 'W', purple: 'P' }.freeze
  KEYS = POSSIBLE_COLORS.keys
  VALUES = POSSIBLE_COLORS.values

  all_possibilities = []
  VALUES.repeated_permutation(4) { |permutation| all_possibilities << permutation}

  def first_guess
    ['R','R','G','G']
  end

  def next_guess(feedback, guess)
  end
end

class Game
  include Input
  include Output
  attr_accessor :board, :lines, :maker, :breaker, :won

  def initialize
    @lines = create_board
    @won = false
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
      guess = breaker.make_guess
      sub_lines(lines[i], guess.colors)
      sub_feedback(lines[i], maker.code.feedback(guess.colors))
      update_board(lines)
      if guess.check_guess?(maker.code)
        self.won = true
        show_code
        break
      end
      i += 1
    end
    false
  end

  def show_code
    if won == true
      sub_lines(lines.last, maker.code.colors)
      update_board(lines)
      puts "*************************\n"\
           "**YOU FOUND THE CODE!!!**\n"\
           '*************************'
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
  attr_accessor :code

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
  end
end

class Code < Sequence
  attr_reader :code

  def initialize(player_type)
    if player_type == 'human'
      puts "************************\n"\
           "*****PICK YOUR CODE*****\n"\
           '************************'
    end
    super(player_type)
    @code = colors
  end

  def feedback(guess)
    feedback = []
    i = 0
    while i < code.length
      feedback_value = array_comparison(code, guess, i)
      feedback << feedback_value unless feedback_value.nil?
      i += 1
    end
    extra_plus = compare_hash(count_ocurrences(code), count_ocurrences(guess))
    i = 0
    while i < extra_plus
      feedback.delete_at(feedback.index('+'))
      i += 1
    end
    feedback
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

  def check_guess?(code)
    colors == code.colors
  end
end

game = Game.new
game.create_players
game.set_code
game.guessing
