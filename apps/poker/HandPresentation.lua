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
         player.status:update()
      end
   end
   
   local function remove_chips()
      for key, player in pairs( ctrl:get_players() ) do
         if player.betChips then
            screen:remove(player.betChips.group)
            player.betChips = nil
         end
      end
   end
   
   local function add_chips()
      
      remove_chips()
      
      for key, player in pairs( ctrl:get_players() ) do
         if not player.betChips then
            player.betChips = chipCollection()
            player.betChips.group.position = {model.default_bet_locations[player.table_position][1], model.default_bet_locations[player.table_position][2]-150}
            screen:add(player.betChips.group)
            player.betChips.group:raise_to_top()
         end
      end
   end
   
   -- Flip all cards up at the end of the hand
   local function all_cards_up()
      for _,card in pairs(allCards) do
         print(card)
         if not card.group.extra.face then
            flipCard(card.group)
         end
      end
   end
   
   function pres:display_hand()
   	add_chips()
      update_players()
   end

   function pres:deal_hole()
      add_chips()
      update_players()
      
      -- just make them all appear in front of the appropriate players
      local hole_cards = ctrl:get_hole_cards()
      y=100
      for player,hole in pairs(hole_cards) do
--         player.betChips.group:animate{position = model.potchips.group.position, duration=500, mode="EASE_OUT_QUAD", on_completed = function() model.potchips:set(3) model.potchips:arrange(55, 5) end}
      
         local card1, card2 = unpack(hole)
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
      add_chips()
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
      add_chips()
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
      add_chips()
      update_players()   
      
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
      -- clear cards
      for key,card in pairs(allCards) do
         screen:remove(card.group)
         resetCardGroup(card.group)
         allCards[key] = nil
      end
      
      -- reset bets
      remove_chips()
   end

   function pres.showdown(pres, winners)
      all_cards_up()
      -- winners is an array of the winning players
   end

   function pres.fold_player(pres, active_player)
      update_players()
   end

   function pres.bet_player(pres, active_player)
      update_players()
   end
end)
