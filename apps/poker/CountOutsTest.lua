dofile("ClassLoader.lua")
local hand = {
   Card("FIVE","HEARTS"),
   Card("SIX","HEARTS"),
   Card("SEVEN","HEARTS"),
   Card("EIGHT","HEARTS"),
}
local out_table = count_outs(hand)
for poker_hand, outs in pairs(out_table) do
   print(poker_hand.name .. ": " .. outs .. " outs")
end