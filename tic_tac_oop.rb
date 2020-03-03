class Board
  attr_accessor :squares

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # Horizontal
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # Vertical
                  [[1, 5, 9], [3, 5, 7]] # Diagonal

  def initialize
    @squares = {}
    clear_markers
  end

  def clear_markers
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def three_in_a_row?(specified_squares)
    !(specified_squares.map(&:marker).include?(Square.new.marker)) &&
      specified_squares.map(&:marker).count(specified_squares[0].marker) == 3
  end

  def winning_marker
    return nil if winning_line.nil?
    @squares[winning_line[0]].marker
  end

  def winning_line
    WINNING_LINES.each do |line|
      specified_squares = @squares.values_at(*line)
      if three_in_a_row?(specified_squares)
        return line
      end
    end
    nil
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |   "
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]} "
    puts "     |     |   "
    puts "-----|-----|-----"
    puts "     |     |   "
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]} "
    puts "     |     |   "
    puts "-----|-----|-----"
    puts "     |     |   "
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]} "
    puts "     |     |   "
  end

  def numerical_representation
    puts "     |     |   "
    puts "  1  |  2  |  3 "
    puts "     |     |   "
    puts "-----|-----|-----"
    puts "     |     |   "
    puts "  4  |  5  |  6 "
    puts "     |     |   "
    puts "-----|-----|-----"
    puts "     |     |   "
    puts "  7  |  8  |  9 "
    puts "     |     |   "
  end
  # rubocop:enable Metrics/AbcSize

  def []=(key, value)
    @squares[key].marker = value
  end
end

class Square
  INITIAL_MARKER = ' '
  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

class Player
  attr_reader :marker

  def initialize(marker)
    @marker = marker
  end
end

class TTTGame
  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'
  FIRST_TO_MOVE = HUMAN_MARKER

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
    @current_player_turn = HUMAN_MARKER
  end

  def play
    clear
    display_welcome_message
    press_any_key_to('begin')
    match
    clear
    display_goodbye_message
  end

  private

  attr_accessor :board, :human, :computer, :current_player_turn

  def match
    loop do
      display_board
      loop do
        current_player_moves
        switch_turns
        break if board.someone_won? || board.full?
        clear_screen_and_display_board
      end
      display_result
      break unless play_again?
      reset
      display_play_again_message
      press_any_key_to('start a new game!')
    end
  end

  def human_moves
    square = nil
    unmarked_keys = board.unmarked_keys
    loop do
      puts "Choose a square between (#{unmarked_keys.join(', ')}):"
      square = gets.chomp
      display_board_with_number_interface if square == 'd'.downcase
      break if unmarked_keys.include?(square.to_i)
      puts "Sorry that's not a valid choice" unless square == 'd'.downcase
    end

    @board[square.to_i] = @human.marker
  end

  def computer_moves
    puts "Computer is calculating its move"
    loading
    @board[board.unmarked_keys.sample] = @computer.marker
  end

  def loading
    3.times do
      print '.'
      sleep 0.32
    end
  end

  def press_any_key_to(str)
    puts "Press any key to #{str}"
    gets.chomp
    clear
  end

  def display_board_with_number_interface
    clear_and_display_board_with_numbers
    press_any_key_to('return to game board')
    clear_screen_and_display_board
  end

  def clear_and_display_board_with_numbers
    clear
    puts ''
    puts "Board with each square containing its corresponding number"
    puts ''
    puts ''
    board.numerical_representation
    puts ''
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ''
  end

  def display_goodbye_message
    puts "Thank you for playing Tic Tac Toe! Goodbye"
    puts ''
  end

  def display_result
    clear
    emphasize_result
    case board.winning_marker
    when HUMAN_MARKER
      puts 'You won!'
    when COMPUTER_MARKER
      puts 'Computer won'
    else
      puts "It's a tie"
    end
  end

  def emphasize_result
    3.times do
      clear
      display_board
      sleep 0.35
      clear
      display_emphasized_winning_board
      sleep 0.35
    end
    clear
    display_board
  end

  def display_emphasized_winning_board
    puts "You're a #{human.marker}. Computer is a #{computer.marker}."
    puts ''
    puts "To see the board with its corresponding numbers press 'd'"
    puts ''
    emphasized_winning_board
    puts ''
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ''
  end

  def emphasized_winning_board
    winning_line = board.winning_line
    winning_board = Board.new

    unless winning_line.nil?
      counter = 1
      9.times do
        if winning_line.include?(counter)
          winning_board[counter] = '*'
        else
          winning_board[counter] = board.squares[counter].marker
        end
        counter += 1
      end
    end

    winning_board.draw
  end

  def display_board
    puts "You're a #{human.marker}. Computer is a #{computer.marker}."
    puts ''
    puts "To see the board with its corresponding numbers press 'd'"
    puts ''
    board.draw
    puts ''
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def play_again?
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      return true if answer == 'y'
      return false if answer == 'n'
      puts "Please type 'y' or 'n'"
    end
  end

  def clear
    system 'clear'
  end

  def reset
    board.clear_markers
    self.current_player_turn = FIRST_TO_MOVE
    clear
  end

  def human_turn?
    current_player_turn == HUMAN_MARKER
  end

  def computer_turn?
    current_player_turn == COMPUTER_MARKER
  end

  def switch_turns
    if human_turn?
      self.current_player_turn = COMPUTER_MARKER
    elsif computer_turn?
      self.current_player_turn = HUMAN_MARKER
    end
  end

  def current_player_moves
    if human_turn?
      human_moves
    elsif computer_turn?
      computer_moves
    end
  end
end

TTTGame.new.play
