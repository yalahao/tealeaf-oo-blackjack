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
    display = ""
    cards.each {|card|  display << "#{card} "}
    display
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

class Player
  attr_accessor :hand, :money, :name

  def initialize
    @hand = Hand.new
  end
end

class Human < Player

  def initialize
    super
    @money = 1000
    puts "Hello, what is your name?"
    @name = gets.chomp
  end

end

class Dealer < Player
  def initialize
    super
    @money = 10000
    @name = "Dealer"
end

class Round
  attr_accessor :player. :bet

  def initialize(player, bet)
    @player = player
    @bet = bet
  end

  def set_new_bet
    if player.class == Dealer
      valid_bet?(bet)
    elsif (player.class = Human) && (bet == 0)
      puts "How much do you want to bet?"
      new_bet = gets.chomp.to_i
      if valid_bet?(new_bet)
        bet = new_bet
      else
        set_new_bet
      end
    else
      puts "Do you want to double down? [Y/N]"
      answer = gets.chomp.downcase
      if !['y', 'n'].include?(answer)

    end
  ...
  end

  protected

  def valid_bet?(b)
    if !(1..50).include?(b)
      puts "Minimum bet of $1. Maximum $50. Try again."
      return nil
    elsif (player.money < bet) && (player.class = Dealer)
      puts "The Dealer ran out of money!"
      abort
    elsif player.money < bet
      puts "#{player.name} doesn't have that much money. Try again"
      return nil
    else
      return true
    end
  end






  end

  def next

  end

end

class Game
  attr_accessor :players, :deck
end

deck = Deck.new
deck.add_full_deck
deck.shuffle

hand = Hand.new
4.times do
  hand.cards << deck.cards[0]
  deck.cards.shift
end
puts hand
puts hand.total_score



