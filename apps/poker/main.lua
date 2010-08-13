dofile("Class.lua") -- Must be declared before any class definitions.
dofile("Globals.lua")
--dofile("Utils.lua")
dofile("MVC.lua")
dofile("Views.lua")
dofile("Chip.lua")
dofile("Player.lua")
dofile("Popup.lua")

Components = {
    CHARACTER_SELECTION = 1,
    PLAYER_BETTING = 2
}

Components.COMPONENTS_LAST = 2
Components.COMPONENTS_FIRST = 1


-- Model initialization
local model = Model()


-- View/Controller initialization
BettingView(model):initialize()
CharacterSelectionView(model):initialize()

function screen:on_key_down(k)
    assert(model:get_active_controller())
    print("current comp: "..model:get_active_component())
    model:get_active_controller():on_key_down(k)
end

model:start_app(Components.CHARACTER_SELECTION)

--[[
math.randomseed(os.time())
dofile("Class.lua")
dofile("Cards.lua")
dofile("Globals.lua")
dofile("Utils.lua")
dofile("PokerRules.lua")
dofile("PokerRulesTest.lua")
dofile("CountOutsTest.lua")
dofile("Popup.lua")

local img = Image{
   src="assets/pokerTable.png"
}

screen:add(img)
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
   local x = 350
   for _,card in ipairs(hand1) do
      local card_text = Text{
         y=y,
         text=card.name,
         color="FFFFFF",
         font="Sans 40px"
      }
      local card_image = Image{ src="assets/cards/"..getCardImageName(card)..".png", y = 0, x=x }
      hand1_group:add(card_text, card_image)
      y = y+card_text.h+10
      x = x+card_image.w+2
   end

   local y = 0
   local x = 400
   for _,card in ipairs(hand2) do
      print(card.name)
      local card_text = Text{
         y=y,
         text=card.name,
         color="FFFFFF",
         font="Sans 40px"
      }
      local card_image = getCardGroup(card, {y=screen.h/2,x=x})
      hand2_group:add(card_text, card_image)
      y = y+card_text.h+10
      x = x+card_image.w+2
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
   
   if k == keys.s then
      hand2_group:foreach_child( function(child)
         if not child.text then
            child.anchor_point = {child.w/2, child.h/2}
            flipCard(child)
            ---
            child.y_rotation = {child.y_rotation[1]+20, 0, 0}
            if child.y_rotation[1]%360 >= 90 and child.y_rotation[1]%360 <= 270 then 
               child:find_child("back"):raise_to_top()
            else
               child:find_child("front"):raise_to_top()
            end
            --]
         end
      end )
   end
end
--]]

local p = Popup:new{draw = true, text="You're Playing Poker Dogs"}
p:render()
