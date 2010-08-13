-- ctrl:get_community_cards()
-- ctrl:get_hole_cards()
-- ctrl:get_player_bets()
-- ctrl:get_pot()
-- ctrl:get_action()
-- ctrl:get_players()
-- ctrl:get_sb_qty()
-- ctrl:get_bb_qty()
-- ctrl:get_sb_p()
-- ctrl:get_bb_p()
-- ctrl:get_deck()

HandPresentation = Class(nil,
function(pres, ctrl)
   local ctrl = ctrl
   
   local allCards = {}
   
   function pres.display_hand(pres)
   end

   function pres.deal_hole(pres)
      -- just make them all appear in front of the appropriate players
      local hole_cards = ctrl:get_hole_cards()
      y=100
      for player,hole in pairs(hole_cards) do
         local card1, card2 = unpack(hole)
         card1.group.position = {100, y}
         card2.group.position = {200, y}
         screen:add(card1.group, card2.group)
         y = y + 200
         flipCard(card1.group)
         flipCard(card2.group)
         table.insert(allCards, card1)
         table.insert(allCards, card2)
      end
      local text_str = "Dealing hole cards"
      screen:add(text)
   end
   function pres.deal_flop(pres)
   
      --[[
      local text_str = "Dealing flop cards"
      local text = Text{
         font="Sans 40px",
         color="FFFFFF",
         text=text_str,
         position={120,120}
      }
      screen:add(text)
      --]]
      
      local cards = ctrl:get_community_cards()
      local x = 750
      local y = 650
      for i=1, 3 do
         cards[i].group.position = {x, y}
         screen:add(cards[i].group)
         x = x + 100
         flipCard(cards[i].group)
         table.insert(allCards, cards[i])
      end
      
   end
   
   function pres.deal_turn(pres)
      local cards = ctrl:get_community_cards()
      local x = 1050
      local y = 650
      local i = 4
      cards[i].group.position = {x, y}
      screen:add(cards[i].group)
      flipCard(cards[i].group)
      table.insert(allCards, cards[i])
   end
   
   function pres.deal_river(pres)
      local cards = ctrl:get_community_cards()
      local x = 1150
      local y = 650
      local i = 5
      cards[i].group.position = {x, y}
      screen:add(cards[i].group)
      flipCard(cards[i].group)
      table.insert(allCards, cards[i])
   end

   function pres.clear_ui(pres)
      for key,card in pairs(allCards) do
         screen:remove(card.group)
         resetCardGroup(card.group)
         allCards[key] = nil
      end
   end
end)