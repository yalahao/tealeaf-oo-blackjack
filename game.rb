require 'pry'

# Modelling
=begin

Game
  new
  start_round
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
      ace_count.time do
        total -= 10 if total > 21
      end
    end
    total
  end
end

deck = Deck.new
deck.add_full_deck
deck.shuffle
puts deck



