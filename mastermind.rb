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

  def pick_human
    colors = []
    colors << ask_colors while colors.length < 4
    colors
  end

  def pick_computer
    colors = []
    colors << VALUES.sample while colors.length < 4
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

  all_possibilities = []
  VALUES.repeated_permutation(4) { |permutation| all_possibilities << permutation }

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

  def feedback(code, guess)
    feedback = []
    i = 0
    while i < code.length
      feedback_value = array_comparison(code, guess, i)
      feedback << feedback_value unless feedback_value.nil?
      i += 1
    end
    i = 0
    while i < compare_hash(count_ocurrences(code), count_ocurrences(guess))
      feedback.delete_at(feedback.index('+'))
      i += 1
    end
    feedback
  end

  def sub_feedback(line, feedback_array)
    feedback_array.shuffle.each do |feedback|
      line.sub!('.', feedback)
    end
    line
  end

  def computer_next_guess(feedback, last_guess)
    all_possibilities.each do |possibility|
      all_possibilities.delete(possibility) if feedback(possibility, last_guess) == feedback
    end
    possibilities[0]
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
      sub_feedback(lines[i], maker.code.give_feedback(guess.colors))
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
  attr_reader :guess

  def initialize(type)
    super
  end

  def make_guess
    @guess = Guess.new(type)
  end
end

class Sequence
  include Input
  include Output
  attr_reader :colors, :current_feedback

  def initialize(player_type)
    case player_type
    when 'human'
      @colors = pick_human
    when 'computer'
      @colors = pick_computer
    end
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

  def give_feedback(guess)
    @current_feedback = feedback(code, guess)
  end
end

class Guess < Sequence
  include Output
  attr_reader :guess

  @@guess_number = 1

  def initialize(player_type)
    case player_type
    when 'human'
      puts "*************************\n"\
           "*****PICK YOUR GUESS*****\n"\
           '*************************'
      super(player_type)
    when 'computer'
      if @@guess_number == 1
        @colors = %w[R R B B]
      else
        @colors = computer_next_guess(current_feedback, guess)
      end
    end
    @guess = colors
    @@guess_number += 1
  end

  def check_guess?(code)
    colors == code.colors
  end
end

game = Game.new
game.create_players
game.set_code
game.guessing
