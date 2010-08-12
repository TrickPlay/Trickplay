dofile("ClassLoader.lua")
local hand = {
   Card("FIVE","HEARTS"),
   Card("SIX","HEARTS"),
   Card("SEVEN","HEARTS"),
   Card("EIGHT","HEARTS"),
}
local out_table = count_outs(hand)
assert(out_table[FLUSH] == 9)
assert(out_table[STRAIGHT] == 8)
assert(out_table[STRAIGHT_FLUSH] == 2)
assert(out_table[ONE_PAIR] == 12)
out_table = count_outs{
   Card("ACE","DIAMONDS"),
   Card("TWO","HEARTS"),
   Card("FOUR","DIAMONDS"),
   Card("SIX","SPADES"),
   Card("QUEEN","SPADES"),
   Card("QUEEN","DIAMONDS"),
}
for poker_hand, outs in pairs(out_table) do
   print(poker_hand.name .. ": " .. outs .. " outs")
end