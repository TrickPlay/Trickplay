dofile("Cards.lua")
dofile("PokerRules.lua")
local hand1 = {
   Card(Ranks.ACE, Suits.SPADES),
   Card(Ranks.ACE, Suits.HEARTS),
   Card(Ranks.KING, Suits.SPADES),
   Card(Ranks.QUEEN, Suits.SPADES),
   Card(Ranks.NINE, Suits.SPADES),
}

local hand2 = {
   Card(Ranks.ACE, Suits.SPADES),
   Card(Ranks.ACE, Suits.HEARTS),
   Card(Ranks.KING, Suits.SPADES),
   Card(Ranks.QUEEN, Suits.SPADES),
   Card(Ranks.TEN, Suits.SPADES),
}

assert(ONE_PAIR.comparator(hand1, hand2) == 1)

hand1 = {
   Card("ACE","SPADES"),
   Card("FOUR","DIAMONDS"),
   Card("THREE","SPADES"),
   Card("SIX","HEARTS"),
   Card("TEN","CLUBS"),
   Card("FOUR","SPADES"),
   Card("SEVEN","CLUBS")
}

hand2 = {
   Card("FIVE","SPADES"),
   Card("FIVE","CLUBS"),
   Card("THREE","CLUBS"),
   Card("SIX","HEARTS"),
   Card("TEN","CLUBS"),
   Card("FOUR","SPADES"),
   Card("SEVEN","CLUBS")
}
assert(ONE_PAIR.comparator(hand1, hand2) == 1,
       "comparator: " .. tostring(ONE_PAIR.comparator(hand1, hand2)))

hand1 = {
   Card("FIVE","SPADES"),
   Card("FIVE","DIAMONDS"),
   Card("FIVE","HEARTS"),
   Card("SIX","HEARTS"),
   Card("TEN","CLUBS"),
   Card("FOUR","SPADES"),
   Card("SEVEN","CLUBS")
}
   
hand2 = {
   Card("JACK","SPADES"),
   Card("JACK","DIAMONDS"),
   Card("JACK","HEARTS"),
   Card("SIX","HEARTS"),
   Card("TEN","CLUBS"),
   Card("FOUR","SPADES"),
   Card("SEVEN","CLUBS")
}
assert(THREE_OF_A_KIND.comparator(hand1, hand2) == 1)
