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
  deal_to(hand)
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

class Deck
  attr_accessor :cards

  def initialize
    @cards = [ ]
  end

  def add_full_deck
    [CLUB, HEART, SPADE, DIAMOND].each do |suit|
      RANKS.each do |rank|
        card = Card.new(suit, rank)
        @cards << card
      end
    end
    binding.pry
  end
end


card = Card.new(DIAMOND, 'A')
deck = Deck.new
deck.add_full_deck
binding.pry


