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
  def total_score
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

  def start
    deck.add_full_deck
    deck.shuffle
    2.times {player.hit(deck)}
    2.times {dealer.hit(deck)}
    overview
    turn(player)
  end

  def turn(person)
    overview
    if person.class == Player
      person.update_bet
      person.hit_or_stay
    else
      person.hit_or_stay
    end
  end

  def overview
    system 'clear'
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

end

Game.new.start
