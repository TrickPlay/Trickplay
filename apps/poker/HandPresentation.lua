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
   
   local function update_players()
      for player, bet in pairs( ctrl:get_player_bets() ) do
         player.betChips:set(bet)
         player.betChips:arrange(55, 5)
         player.status:update()
      end
   end
   
   local function all_cards_up()
      --[[
      for _,card in pairs(allCards) do
         print(card)
         if card.group.extra.face == "back" then
            print("Flipped!")
            flipCard(card.group)
            print("Ok!")
         end
      end
      --]]
      for player, hole in pairs( ctrl:get_hole_cards() ) do
         local card1, card2 = unpack(hole)
         if not card1.group.extra.face then
            print(card1.group.extra.face, card2.group.extra.face)
            flipCard(card1.group)
            flipCard(card2.group)
         end
      end
      
      --debug()
   end
   
   function pres.display_hand(pres)
      -- Update player bets and money
      update_players()
   end

   function pres.deal_hole(pres)
      update_players()
      -- just make them all appear in front of the appropriate players
      local hole_cards = ctrl:get_hole_cards()
      y=100
      for player,hole in pairs(hole_cards) do
         local card1, card2 = unpack(hole)
         assert(model.default_bet_locations)
         assert(model.default_bet_locations[player.table_position]) 
         card1.group.position = {model.default_bet_locations[player.table_position][1], model.default_bet_locations[player.table_position][2]}
         card2.group.position = {model.default_bet_locations[player.table_position][1] + 100, model.default_bet_locations[player.table_position][2]}
         screen:add(card1.group, card2.group)
         y = y + 200
         if player.isHuman then
            flipCard(card1.group)
            flipCard(card2.group)
         end
         table.insert(allCards, card1)
         table.insert(allCards, card2)
      end
      local text_str = "Dealing hole cards"
      screen:add(text)
   end
   function pres.deal_flop(pres)
      update_players()

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
      update_players()
      
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
      update_players()   
      
      local cards = ctrl:get_community_cards()
      local x = 1150
      local y = 650
      local i = 5
      cards[i].group.position = {x, y}
      screen:add(cards[i].group)
      flipCard(cards[i].group)
      table.insert(allCards, cards[i])
      
      all_cards_up()
   end

   function pres.clear_ui(pres)
      -- clear cards
      for key,card in pairs(allCards) do
         screen:remove(card.group)
         resetCardGroup(card.group)
         allCards[key] = nil
      end
      
      -- reset bets
      local player_bets = ctrl:get_player_bets()
      for player, bet in pairs(player_bets) do
         player.betChips:set(0)
      end
   end
end)
