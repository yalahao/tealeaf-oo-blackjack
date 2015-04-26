require 'pry'

CLUB = "\u2664 ".encode('utf-8')
HEART = "\u2661 ".encode('utf-8')
SPADE = "\u2667 ".encode('utf-8')
DIAMOND= "\u2662 ".encode('utf-8')
SUITS = [CLUB, HEART, SPADE, DIAMOND]
RANKS = %w{A 2 3 4 5 6 7 8 9 J Q K}
MAX_BET = 100
DECKS_OF_CARDS = 2

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
end

class Deck < CardCollection
  def reshuffle
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
    sleep 1
  end
end

class Player < Person
  attr_accessor :money, :bet

  def initialize
    super
    @money = 1000
    @bet = 0
  end

  def set_name
    puts "Enter player's name:"
    @name = gets.chomp.to_s
  end

  def update_bet
    if bet == 0
      place_bet
    else
      double_down
    end
  end

  def place_bet
    max_bet = [MAX_BET, @money].min
    puts "Minimum bet of $1. Maximum bet of $#{max_bet}."
    puts "How much does #{name} want to bet?"
    new_bet = gets.chomp.to_i
    if (1..max_bet).include?(new_bet)
      @bet = new_bet
      @money -= new_bet
      puts "#{name} placed a bet of $#{bet}"
    else
      puts "Invalid bet. Try again."
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
        @money -= bet
        @bet += bet
        puts "#{name} doubled down! The bet is now $#{bet}."
      else
        puts "The bet stayed at $#{bet}."
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

  def start
    system 'clear'
    if !player.name
      player.set_name
    end
    @deck = Deck.new
    deck.reshuffle
    player.hand = Hand.new
    dealer.hand = Hand.new
    overview
    puts "#{player.name}'s turn"
    puts "-----------------------"
    player.update_bet
    2.times {player.hit(deck)}
    2.times {dealer.hit(deck)}
    player_turn
    dealer_turn
    end_round
    play_again
  end

  def player_turn
    check_score(player)
    overview
    puts "#{player.name}'s turn"
    puts "-----------------------"
    player.update_bet
    player_choice
  end

  def player_choice
    puts "Hit or stay? [H/S]"
    answer = gets.chomp.downcase
    if !['h', 's'].include?(answer)
      puts "Invalid choice. Try again"
      player_choice
    end
    if answer == 'h'
      player.hit(deck)
      check_score(player)
      player_turn
    else
      puts "#{player.name} stayed."
    end
  end

  def dealer_turn
    check_score(dealer)
    overview
    puts "#{dealer.name}'s turn"
    puts "-----------------------"
    if dealer.hand.score < 17
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
    puts "-----------------------"
    winner = Person.new
    p_score = player.hand.score
    d_score = dealer.hand.score
    puts "#{player.name}'s score is #{player.hand.score}."
    puts "#{dealer.name}'s score is #{dealer.hand.score}."
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
    if winner == player
      player.money += (player.bet * 2)
      puts "#{player.name} won $#{player.bet}!"
    elsif winner == dealer
      puts "#{dealer.name} won. #{player.name} lost $#{player.bet}..."
    end
    player.bet = 0
    if player.money == 0
      puts "#{player.name} ran out of money and had to leave..."
      abort
    end
    play_again
  end
end

def play_again
  puts "Play another round? (Y/N)"
  choice = gets.chomp.downcase
  if choice == 'y'
    start
  elsif choice == 'n'
    system 'clear'
    money_diff = player.money - 1000
    if money_diff > 0
      puts "#{player.name} left with $#{money_diff} extra money in the pocket!"
    elsif money_diff < 0
      puts "#{player.name} lost $#{money_diff * -1} and left..."
    else
      puts "#{player.name} left."
    end
    puts "-- THE END --"
    abort
  else
    puts "Invalid choice. Try again."
    play_again
  end
end

Game.new.start
