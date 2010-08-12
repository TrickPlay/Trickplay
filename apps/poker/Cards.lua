if not Class then
   dofile("Class.lua")
end

function Suit(name)
   return {
      name=name,
      abbv=string.sub(name, 1, 1)
   }
end

Suits = {
   CLUBS=Suit("Clubs"),
   DIAMONDS=Suit("Diamonds"),
   HEARTS=Suit("Hearts"),
   SPADES=Suit("Spades")
}

function Rank(name, num, abbv)
   return {
      name=name,
      num=num,
      abbv=abbv
   }
end

Ranks = {
   TWO=Rank("Two", 2, "2"),
   THREE=Rank("Three", 3, "3"),
   FOUR=Rank("Four", 4, "4"),
   FIVE=Rank("Five", 5, "5"),
   SIX=Rank("Six", 6, "6"),
   SEVEN=Rank("Seven", 7, "7"),
   EIGHT=Rank("Eight", 8, "8"),
   NINE=Rank("Nine", 9, "9"),
   TEN=Rank("Ten", 10, "T"),
   JACK=Rank("Jack", 11, "J"),
   QUEEN=Rank("Queen", 12, "Q"),
   KING=Rank("King", 13, "K"),
   ACE=Rank("Ace", 14, "A"),
}

Card = Class(nil, 
function(self, rank, suit)
   if type(rank) == "string" then
      self.rank = Ranks[rank]
   else
      self.rank = rank
   end
   assert(self.rank)

   if type(suit) == "string" then
      self.suit = Suits[suit]
   else
      self.suit = suit
   end
   assert(self.suit)

   self.name = self.rank.name .. " of " .. self.suit.name
   self.abbv = self.rank.abbv .. self.suit.abbv

   function self:equals(card)
      return self.rank == card.rank and self.suit == card.suit
   end
end)

Cards = {}
for _, suit in pairs(Suits) do
   for __, rank in pairs(Ranks) do
      table.insert(Cards, Card(rank, suit))
   end
end

Deck = Class(nil, function(self, ...)
   local cards = {}
   for _, card in ipairs(Cards) do
      table.insert(cards, card)
   end

   function self:shuffle()
      local swapcard
      for i=1,#cards do
         swapcard = math.random(i, #cards)
         cards[i], cards[swapcard] = cards[swapcard], cards[i]
      end
   end

   function self:deal(n)
      assert(n <= #cards)
      local hand = {}
      local card
      for i=1,n do
         card = table.remove(cards)
         table.insert(hand, card)
      end
      return hand
   end

   function self:reset()
      cards = {}
      for _, card in ipairs(Cards) do
         table.insert(cards, card)
      end
   end
end)