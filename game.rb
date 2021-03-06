module Constants
  CLUB = "\u2664 ".encode('utf-8')
  HEART = "\u2661 ".encode('utf-8')
  SPADE = "\u2667 ".encode('utf-8')
  DIAMOND= "\u2662 ".encode('utf-8')
  SUITS = [CLUB, HEART, SPADE, DIAMOND]
  RANKS = %w{A 2 3 4 5 6 7 8 9 J Q K}
  MAX_BET = 100
  DECKS_OF_CARDS = 2
  BLACKJACK = 21
  DELAY = 1
end

class Card
  include Constants
  attr_reader :suit, :rank
  attr_accessor :face_up

  def initialize(suit, rank)
    @suit = suit
    @rank = rank
    @face_up = true
  end

  def to_s
    if @face_up == false
      "**"
    else
      "#{suit}#{rank}"
    end
  end
end

class Deck
  include Constants
  attr_accessor :cards

  def initialize
    @cards = []
  end

  def reshuffle!
    DECKS_OF_CARDS.times do
      SUITS.each do |suit|
        suit_cards = [ ]
        RANKS.each do |rank|
          card = Card.new(suit, rank)
          suit_cards << card
        end
      cards.concat(suit_cards)
      end
    end
    cards.shuffle!
  end
end

class Hand
  include Constants
  attr_accessor :cards

  def initialize
    @cards = []
  end

  def to_s
    if cards == []
     "(none)"
    else
      display = "["
      cards.each {|card|  display << "#{card} "}
      display << "]"
    end
  end

  def score
    total = 0
    cards.each do |card|
      if card.rank == 'A'
        total += 11
      elsif ['J','Q','K'].include?(card.rank)
        total += 10
      else
        total += card.rank.to_i
      end
    end
    # Adjust for aces
    if total > BLACKJACK
      ace_count = 0
      cards.each do |card|
        ace_count +=1 if card.rank == 'A'
      end
      ace_count.times do
        total -= 10 if total > BLACKJACK
      end
    end
    total
  end
end

class Person
  include Constants
  attr_accessor :name, :hand

  def initialize
    @hand = Hand.new
  end

  def hit(deck)
    puts "#{name} hit, #{deck.cards[0]}"
    hand.cards << deck.cards[0]
    deck.cards.shift
    sleep DELAY
  end
end

class Player < Person
  include Constants
  attr_accessor :money, :bet

  def initialize
    super
    @money = 1000
    @bet = 0
  end

  def set_name
    puts ">> Enter player's name:"
    @name = gets.chomp.to_s
  end

  def place_bet
    max_bet = [MAX_BET, @money].min
    puts "Minimum bet of $1. Maximum bet of $#{max_bet}."
    puts ">> How much does #{name} want to bet?"
    new_bet = gets.chomp.to_i
    if (1..max_bet).include?(new_bet)
      @bet = new_bet
      @money -= new_bet
      puts "#{name} placed a bet of $#{bet}"
    else
      puts "Invalid bet. Try again."
      place_bet
    end
    sleep DELAY
  end

  def double_down
    if @bet > money
      return
    else
      puts ">> Double down? [Y/N]"
      answer = gets.chomp.downcase
      if !['y', 'n'].include?(answer)
        puts "Invalid choice. Try again"
        double_down
      end
      if answer == 'y'
        @money -= bet
        @bet += bet
        puts "#{name} doubled the bet to $#{bet}."
      else
        puts "The bet stayed at $#{bet}."
      end
      sleep DELAY
    end

  end

  def to_s
    "#{name} has $#{money}."
    "#{name}'s hand is #{hand}."
  end

  def win_bet
    money += bet
    bet = 0
  end

  def lose_bet
    bet = 0
  end

end

class Dealer < Person
  def initialize
    super
    @name = "Dealer"
  end

  def hit(deck)
    # second card face down for initial dealing
    deck.cards[0].face_up = false if hand.cards.count == 0
    super
  end
end

class Game
  include Constants
  attr_accessor :player, :dealer, :deck, :num_rounds

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
    @num_rounds = 0
  end

  def divider
    puts "-----------------------"
  end

  def overview
    system 'clear'
    divider
    puts "Round #{num_rounds}"
    divider
    puts "#{player.name}:"
    puts "Money: #{player.money}"
    puts "Current bet: #{player.bet}"
    puts "Hand: #{player.hand}"
    divider
    puts "Dealer:"
    puts "Hand: #{dealer.hand}"
    divider
  end

  def new_round
    system 'clear'
    @num_rounds += 1
    if !player.name
      player.set_name
    end
    @deck = Deck.new
    deck.reshuffle!
    player.hand = Hand.new
    dealer.hand = Hand.new
    overview
    puts "#{player.name}'s turn"
    divider
    player.place_bet
    2.times {player.hit(deck)}
    2.times {dealer.hit(deck)}
    check_score(player)
    check_score(dealer)
    player_turn
    dealer_turn
    end_round
    play_again
  end

  def player_turn
    check_score(player)
    overview
    puts "#{player.name}'s turn"
    divider
    player_choice
  end

  def player_choice
    puts ">> Hit, stay or double down? [H/S/D]"
    answer = gets.chomp.downcase
    if !['h', 's', 'd'].include?(answer)
      puts "Invalid choice. Try again"
      player_choice
    end
    case answer
    when 'h'
      player.hit(deck)
      check_score(player)
      player_turn
    when 'd'
      if player.money < player.bet
        puts "#{player.name} doesn't have enough money to double the bet..."
        puts "Try again."
        player_choice
      else
        player.money -= player.bet
        player.bet += player.bet
        puts "#{player.name} doubled the bet to $#{player.bet}."
        sleep DELAY
        player.hit(deck)
        sleep DELAY
        check_score(player)
        player_turn
      end
    when 's'
      puts "#{player.name} stayed."
    end
  end

  def dealer_turn
    first_card = dealer.hand.cards[0]
    first_card.face_up = true if first_card.face_up == false
    check_score(dealer)
    overview
    puts "#{dealer.name}'s turn"
    divider
    sleep DELAY
    if dealer.hand.score < [17, player.hand.score].max
      dealer.hit(deck)
      check_score(dealer)
      dealer_turn
    else
      puts "#{dealer.name} stayed."
    end
  end

  def check_score(person)
    if person.hand.score >= 21
      end_round
    end
  end

  def end_round
    overview
    puts "End of round"
    divider
    puts "#{player.name}'s score is #{player.hand.score}."
    puts "#{dealer.name}'s score is #{dealer.hand.score}."
    sleep DELAY
    if winner == player
      player.money += player.bet * 2
      puts "#{player.name} won $#{player.bet}!"
    elsif winner == dealer
      puts "#{dealer.name} won. #{player.name} lost $#{player.bet}..."
    else
      puts "It's a tie..."
      player.money += player.bet
    end
    player.bet = 0
    sleep DELAY
    if player.money == 0
      puts "After round #{num_rounds}, #{player.name} lost everything and had to leave..."
      abort
    end
    play_again
    end
  end

  def winner
    winner = Person.new
    p_score = player.hand.score
    d_score = dealer.hand.score
    winner = if (p_score == 21) && (d_score == 21)
            nil
            elsif (p_score == 21) || (d_score > 21)
              player
            elsif (p_score > 21) || (d_score == 21)
              dealer
            elsif p_score > d_score
              player
            elsif p_score < d_score
              dealer
            else
              nil
            end
  end

  def play_again
    puts "Play another round? (Y/N)"
    choice = gets.chomp.downcase
    if choice == 'y'
      new_round
    elsif choice == 'n'
      system 'clear'
      money_diff = player.money - 1000
      if money_diff > 0
        puts "After round #{num_rounds}, #{player.name} left with $#{money_diff} extra money in the pocket!"
      elsif money_diff < 0
        puts "After round #{num_rounds}, #{player.name} left with $#{money_diff * -1} loss..."
      else
        puts "After round #{num_rounds}, #{player.name} left."
      end
      puts "--- THE END ---"
      abort
    else
      puts "Invalid choice. Try again."
      play_again
    end
  end

Game.new.new_round

