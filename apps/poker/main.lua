dofile("Class.lua")
dofile("Cards.lua")
local deck = Deck()
deck:shuffle()
local hand1 = deck:deal(5)
local hand2 = deck:deal(5)
print("\n\n\n\n\n\n")
print(#hand1)
for _,card in ipairs(hand1) do
   print(card.name)
end


local hand1_group = Group{position={0,0}}
local y = 0
for _,card in ipairs(hand1) do
   local card_text = Text{
      y=y,
      text=card.name,
      color="FFFFFF"
   }
   hand1_group:add(card_text)
   y = y+card_text.h+10
end
local hand2_group = Group{position={960,0}}
local y = 0
for _,card in ipairs(hand2) do
   print(card.name)
   local card_text = Text{
      y=y,
      text=card.name,
      color="FFFFFF"
   }
   hand2_group:add(card_text)
   y = y+card_text.h+10
end
screen:add(hand1_group, hand2_group)
screen:show()

function screen:on_key_down(k)
   if k == keys.r then
      deck:shuffle()
   end
end