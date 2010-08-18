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
local TIME = 300
local MODE = "EASE_OUT_QUAD"


HandPresentation = Class(nil,
function(pres, ctrl)
   local ctrl = ctrl
   
   local allCards = {}
   
   local poker_hand_text = Text{
      font="Sans 40px",
      color="FFFFFF",
      text="",
      position={100, 200},
      opacity = 255
   }
   screen:add(poker_hand_text)

   -- Update bets and status boxes for all players
   local function update_players()
      for player, bet in pairs( ctrl:get_player_bets() ) do
         player.betChips:set(bet)
         player.status:update()
      end
   end
   
   -- Remove player chips
   local function remove_chips(chips)
      for _, player in pairs( ctrl:get_players() ) do
         if player.betChips then
            if player.betChips.parent then
               screen:remove(player.betChips.group)
            end
            player.betChips = nil
         end
      end
   end
   
   -- Add player chips
   local function add_chips()
      for _, player in pairs( ctrl:get_players() ) do
         player.betChips = chipCollection()
         player.betChips.group.position = { MSCL[player.table_position][1] + 55, MSCL[player.table_position][2] }
         --player.betChips.group.position = {model.default_bet_locations[player.table_position][1], model.default_bet_locations[player.table_position][2]-150}
         screen:add(player.betChips.group)
         player.betChips.group:raise_to_top()
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
   
   local function animate_chips_to_center(player)
      if player then
         local c = player.betChips
         player.betChips.group:animate{
            position = model.potchips.group.position,
            duration=500,
            mode="EASE_OUT_QUAD",
            on_completed = function()
               model.potchips:set( model.potchips:value() + c:value() )
               screen:remove(c.group)
            end
         }
      else
         for _, player in pairs( ctrl:get_players() ) do
            local c = player.betChips
            player.betChips.group:animate{
               position = model.potchips.group.position,
               duration=500,
               mode="EASE_OUT_QUAD",
               on_completed = function()
                  model.potchips:set( model.potchips:value() + c:value() )
                  screen:remove(c.group)
               end
            }
         end
      end
   end
   
   function pres:display_hand()
      -- Initialize chips
      remove_chips()
   	add_chips()
      update_players()
      
      -- Put community cards on the deck
      local cards = ctrl:get_community_cards()
      for i=5,1,-1 do
         cards[i].group.position = MCL.DECK
         cards[i].group:raise_to_top()
      end
      
      -- Put hole cards on the deck
      for player,hole in pairs( ctrl:get_hole_cards() ) do
         for _,card in pairs(hole) do
            card.group.position = MCL.DECK
            card.group:raise_to_top()
         end
      end
   end

   function pres:deal_hole()
      update_players()
      
      for player,hole in pairs( ctrl:get_hole_cards() ) do
         
         local offset = 0
         local pos = {MPCL[player.table_position][1], MPCL[player.table_position][2]}
         
         for k,card in pairs(hole) do
            screen:add(card.group)
            -- Animate and flip the card if the player is human
            card.group:animate{x = pos[1] + offset, y = pos[2] + offset, mode=MODE, duration=TIME, on_completed = function() if player.isHuman then flipCard(card.group) end end }
            card.group:raise_to_top()
            offset = offset + 30
            
            table.insert(allCards, card)
         end
      end
      
      screen:add(text)
   end
   
   function pres:deal_flop()
      animate_chips_to_center()
      add_chips()
      update_players()

      local cards = ctrl:get_community_cards()
      for i=1, 3 do
         cards[i].group:animate{ position = MCL[i], duration = TIME, mode = MODE, z_rotation=-3 + math.random(5), on_completed = function() flipCard(cards[i].group) end }
         screen:add(cards[i].group)
         table.insert(allCards, cards[i])
      end
      
   end
   
   function pres:deal_turn()
      animate_chips_to_center()
      add_chips()
      update_players()
      
      local cards = ctrl:get_community_cards()
      local i = 4
      cards[i].group:animate{ position = MCL[i], duration = TIME, mode = MODE, z_rotation=-3 + math.random(5), on_completed = function() flipCard(cards[i].group) end }
      screen:add(cards[i].group)
      table.insert(allCards, cards[i])
   end
   
   function pres:deal_river()
      animate_chips_to_center()
      add_chips()
      update_players()   
      
      local cards = ctrl:get_community_cards()
      local i = 5
      cards[i].group:animate{ position = MCL[i], duration = TIME, mode = MODE, z_rotation = 0, on_completed = function() flipCard(cards[i].group) end }
      screen:add(cards[i].group)
      table.insert(allCards, cards[i])
      
   end

   function pres.clear_ui(pres)
      poker_hand_text:animate{
         duration=200,
         opacity=0
      }
      -- clear cards
      for key,card in pairs(allCards) do
         screen:remove(card.group)
         resetCardGroup(card.group)
         allCards[key] = nil
      end
      
      -- reset bets
      remove_chips()
   end

   function pres.showdown(pres, winners, poker_hand)
      animate_chips_to_center()
      all_cards_up()
      print(poker_hand.name .. " passed to pres:showdown()")
      --[[
      poker_hand_text.text = poker_hand.name
      poker_hand_text:animate{
         duration=300,
         opacity=255,
      }
      ]]--
      
      -- winners is an array of the winning players
      --[[
      local p_num = winners[1].table_position
      local wintext = "Player "..p_num.. " wins!"
      local t = Text{ font="Sans 50px", color="00FF55", text=wintext, position=MDPL[p_num] }
      
      Popup:new{group = t}
      --]]
      
      winners[1].status:update( poker_hand.name )
      --winners[1].status:update( "I win!" )
      
   end

   function pres:fold_player(active_player)
      animate_chips_to_center(active_player)
      update_players()
   end

   function pres:bet_player(active_player)
      --update_players()
      
      for player, bet in pairs( ctrl:get_player_bets() ) do
         if player == active_player then
            player.betChips:set(bet)
            player.status:update( "Bet "..bet )
         end
      end

   end

   function pres:start_turn(active_player)
   end

   function pres:finish_turn(active_player)
   end
end)
