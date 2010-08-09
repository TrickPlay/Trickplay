function Suit(name)
   return {
      name=name
   }
end

Suits = {
   CLUBS=Suit("Clubs"),
   DIAMONDS=Suit("Diamonds"),
   HEARTS=Suit("Hearts"),
   SPADES=Suit("Spades")
}

function Rank(name, num)
   return {
      name=name,
      num=num
   }
end

Ranks = {
   TWO=Rank("Two", 2),
   THREE=Rank("Three", 3),
   FOUR=Rank("Four", 4),
   FIVE=Rank("Five", 5),
   SIX=Rank("Six", 6),
   SEVEN=Rank("Seven", 7),
   EIGHT=Rank("Eight", 8),
   NINE=Rank("Nine", 9),
   TEN=Rank("Ten", 10),
   JACK=Rank("Jack", 11),
   QUEEN=Rank("Queen", 12),
   KING=Rank("King", 13),
   ACE=Rank("Ace", 14),
}

function Card(rank, suit)
   return {
      rank=rank,
      suit=suit,
      name=rank.name .. " of " .. suit.name
   }
end

Cards = {}
for _, suit in pairs(Suits) do
   for __, rank in pairs(Ranks) do
      table.insert(Cards, Card(rank, suit))
   end
end
print("#Cards", #Cards)
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