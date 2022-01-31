module Mastermind
  class Game
    attr_accessor :code
    attr_reader :feedback

    @possible_code_chars = %w[x y o w z f]

    def initialize
      @rounds = 0
      @turns = 8
      @players = []
      @codemaker = ''
      @codebreaker = ''
      @code = ''
      @feedback = [' ', ' ', ' ', ' ']
      @gameover = false
      start_game
    end

    def self.possible_code_chars
      @possible_code_chars
    end

    def start_game
      setup_game
      @rounds.times do
        play_round
        reset_gameover
      end
    end

    def setup_game
      puts 'How many Rounds of Mastermind do you want to play?'
      @rounds = gets.chomp.to_i
      @players = [Player.new(self), ComputerPlayer.new(self)]
      select_codemaker
    end

    def select_codemaker
      puts 'Do you want to start as Codemaker(1) or as Codebreaker(2)?'
      case gets.chomp
      when '1'
        @codemaker = @players[0]
        @codebreaker = @players[1]
      when '2'
        @codemaker = @players[1]
        @codebreaker = @players[0]
      else
        select_codemaker
      end
    end

    def play_round
      code = @codemaker.create_code
      @turns.times do
        marked_guesses = []
        guess = @codebreaker.make_guess
        @feedback = [' ', ' ', ' ', ' ']
        calculate_feedback(code, guess, marked_guesses)
        sleep 1
        print_gui(code, guess)
        set_gameover(code, guess)
        break if gameover?
      end
      @codemaker, @codebreaker = @codebreaker, @codemaker
    end

    def calculate_feedback(code, guess, marked_guesses)
      guess.each_index do |guess_index|
        if guess[guess_index] == code[guess_index]
          @feedback[guess_index] = '1'
          marked_guesses.push(guess_index)
        else
          puts ''
          p marked_guesses
          code.each_index do |code_index|
            if guess[guess_index] == code[code_index] && !marked_guesses.include?(code_index)
              @feedback[guess_index] = '0'
              marked_guesses.push(code_index)
            end
          end
        end
      end
    end

    def print_gui(code, guess)
      puts ''
      puts ''
      puts ''
      puts 'code:'
      p code
      puts ''
      puts 'Guess:'
      p guess
      p @feedback
    end

    def gameover?
      true if @gameover == true
    end

    def reset_gameover
      @gameover = false
    end

    def set_gameover(code, guess)
      if guess == code
        @feedback = [' ', ' ', ' ', ' ']
        @gameover = true
      end
    end
  end

  class Player
    def initialize(game)
      @game = game
      @points = 0
      @last_guess = []
      @guess = ['', '', '', '']
    end

    def create_code
      valid_code = true
      puts 'pls create your Code using the allowed characters.'
      puts "Allowed characters: #{Game.possible_code_chars}"
      new_code = gets.chomp.split(//)
      new_code.each do |char|
        if !Game.possible_code_chars.include?(char) || new_code.length != 4
          valid_code = false
          create_code
          break
        end
      end
      @game.code = new_code if valid_code
    end

    def make_guess
      valid_guess = true
      puts 'pls enter your guess.'
      guess = gets.chomp.split(//)
      guess.each do |char|
        if !Game.possible_code_chars.include?(char) || guess.length !=4
          valid_guess = false
          make_guess
          break
        end
      end
      @guess = guess if valid_guess
      @guess
    end
  end

  class ComputerPlayer < Player
    def create_code
      Game.possible_code_chars.sample(4)
    end

    def make_guess
      @game.feedback.each_index do |index|
        if @game.feedback[index] != '1'
          @last_guess[index] = Game.possible_code_chars.sample
        end
      end
      # guess = Game.possible_code_chars.sample(4)
      
      @last_guess
    end
  end
end

include Mastermind

Game.new
