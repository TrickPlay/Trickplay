

math.randomseed(os.time())
dofile("Class.lua")
dofile("Cards.lua")
dofile("Globals.lua")
dofile("Utils.lua")
dofile("PokerRules.lua")
dofile("PokerRulesTest.lua")
local deck = Deck()
deck:shuffle()
local hand1 = deck:deal(5)
local hand2 = deck:deal(5)

local hand1_group = Group{position={0,0}}
local hand2_group = Group{position={960,0}}
screen:add(hand1_group, hand2_group)
screen:show()
function display_cards()
   hand1_group:clear()
   hand2_group:clear()
   local y = 0
   for _,card in ipairs(hand1) do
      local card_text = Text{
         y=y,
         text=card.name,
         color="FFFFFF",
         font="Sans 40px"
      }
      hand1_group:add(card_text)
      y = y+card_text.h+10
   end

   local y = 0
   for _,card in ipairs(hand2) do
      print(card.name)
      local card_text = Text{
         y=y,
         text=card.name,
         color="FFFFFF",
         font="Sans 40px"
      }
      hand2_group:add(card_text)
      y = y+card_text.h+10
   end
end

display_cards()

function screen:on_key_down(k)
   if k == keys.r then
      deck:reset()
      deck:shuffle()
      hand1=deck:deal(5)
      hand2=deck:deal(5)
      display_cards()
      print("One pair present in hand1:",ONE_PAIR.present_in(hand1))
      print("One pair present in hand2:",ONE_PAIR.present_in(hand2))
      if res == 1 then
         print("hand 2 wins")
      elseif res == -1 then
         print("hand 1 wins")
      else
         print("tie.")
      end
   end
end
