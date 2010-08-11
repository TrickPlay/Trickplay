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

function Card(rank, suit)
   if type(rank) == "string" then
      rank = Ranks[rank]
      assert(rank)
   end
   if type(suit) == "string" then
      suit = Suits[suit]
      assert(suit)
   end
   return {
      rank=rank,
      suit=suit,
      name=rank.name .. " of " .. suit.name,
      abbv=rank.abbv .. suit.abbv
   }
end

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