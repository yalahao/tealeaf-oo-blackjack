require 'pry'

# Modelling
=begin

Game
  new
  start_round
  deal_to(player)
  compare(hand, hand)
  play_again_or_quit

Round
  @current_player

Player
  @hand
Human < Player
  hit_or_stay
Computer < Player
  hit_or_stay

Card
  @suit
  @rank
  display
Deck
  @cards
  shuffle
Hand
  @cards
  total_score
  show
  sort

=end

CLUB = "\u2664 ".encode('utf-8')
HEART = "\u2661 ".encode('utf-8')
SPADE = "\u2667 ".encode('utf-8')
DIAMOND= "\u2662 ".encode('utf-8')
SUITS = [CLUB, HEART, SPADE, DIAMOND]
RANKS = %w{A 2 3 4 5 6 7 8 9 J Q K}

class Card
  attr_reader :suit, :rank

  def initialize(suit, rank)
    @suit = suit
    @rank = rank
  end

  def to_s
    "#{suit}#{rank}"
  end
end

class CardCollection
  attr_accessor :cards

  def initialize
    @cards = [ ]
  end

  def to_s
    display = "["
    cards.each {|card|  display << "#{card} "}
    display << "]"
  end
end

class Deck < CardCollection
  def add_full_deck
    SUITS.each do |suit|
      suit_cards = [ ]
      RANKS.each do |rank|
        card = Card.new(suit, rank)
        suit_cards << card
      end
    cards.concat(suit_cards)
    end
  end

  def shuffle
    cards.shuffle!
  end
end

class Hand < CardCollection
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
    if total > 21
      ace_count = 0
      cards.each do |card|
        ace_count +=1 if card.rank == 'A'
      end
      ace_count.times do
        total -= 10 if total > 21
      end
    end
    total
  end
end

class Person
  attr_accessor :name, :hand

  def initialize
    @hand = Hand.new
  end

  def hit(deck)
    puts "#{name} hit, #{deck.cards[0]}"
    hand.cards << deck.cards[0]
    deck.cards.shift
  end

  def blackjack_or_busted
    if hand.score >= 21
      end_game
    end
  end

end

class Player < Person
  attr_accessor :money, :bet

  def initialize
    super
    @money = 1000
    @bet = 0
    puts "Hello, what is your name?"
    @name = gets.chomp
  end

  def update_bet
    if bet == 0
      place_bet
    else
      double_down
    end
    hit_or_stay
  end

  def place_bet
    puts "How much do you want to bet?"
    new_bet = gets.chomp.to_i
    max_bet = [50, @money].min
    if (1..max_bet).include?(new_bet)
      @bet = new_bet
      puts "#{name} placed a bet of $#{bet}"
    else
      puts "Minimum bet of $1. Maximum bet of $#{max_bet}. Try again."
      place_bet
    end
  end

  def double_down
    if (@bet * 2) > money
      return
    else
      puts "Double down? [Y/N]"
      answer = gets.chomp.downcase
      if !['y', 'n'].include?(answer)
        puts "Invalid choice. Try again"
        double_down
      end
      if answer == 'y'
        @bet += @bet
        puts "#{name} doubled down! The bet is now $#{bet}."
      else
        puts "The bet stays at $#{bet}."
      end
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
end

class Game
  attr_accessor :player, :dealer, :deck

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def overview
    # system 'clear'
    puts "-----------------------"
    puts "#{player.name}:"
    puts "Money: #{player.money}"
    puts "Current bet: #{player.bet}"
    puts "Hand: #{player.hand}"
    puts "-----------------------"
    puts "Dealer:"
    puts "Hand: #{dealer.hand}"
    puts "-----------------------"
  end

  def start
    deck.add_full_deck
    deck.shuffle
    2.times {player.hit(deck)}
    2.times {dealer.hit(deck)}
    player_turn
    dealer_turn
    end_game
    play_again
  end

  def player_turn
    overview
    player.update_bet
    player_choice
  end

  def player_choice
    puts "Hit or stay?"
    answer = gets.chomp.downcase
    if !['hit', 'stay'].include?(answer)
      puts "Invalid choice. Try again"
      player_choice
    end
    if answer == 'hit'
      player.hit(deck)
      overview
      player.blackjack_or_busted
      player_turn
    else
      puts "#{player.name} stayed."
    end
  end

  def dealer_turn
    overview
    if dealer.hand.score < 17
      dealer.hit(deck)
      dealer.blackjack_or_busted
      dealer_turn
    else
      puts "#{dealer.name} stayed."
    end
  end

  def end_game
    winner = Person.new
    p_score = player.hand.score
    d_score = dealer.hand.score
    if (p_score == 21) || (d_score > 21)
      winner = player
    elsif (p_score > 21) || (d_score == 21)
      winner = dealer
    elsif p_score > d_score
      winner = player
    elsif p_score < d_score
      winner = dealer
    else
      puts "It's a tie..."
    end
    if winner = player
      player.money += (player.bet * 2)
      puts "#{player.name} won!"
    elsif winner = dealer
      puts "#{dealer.name} won."
    end
    player.bet = 0
    play_again?
  end
end

Game.new.start
