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

--realPrint = print
--print = function() end
local print = function() end --realPrint

HandPresentation = Class(nil,function(pres, ctrl)
   local ctrl = ctrl
   local allCards = {}
   
   local potText = Text{ font = PLAYER_ACTION_FONT, color = "BFB800", text = "Ammount", position = MDBL.POT}
   on_text_changed = function()
      potText.anchor_point = {potText.w/2, potText.h/2}
   end
   potText.y = potText.y + 60
   --potText.x = potText.x + 20
   screen:add(potText)

   -------------------------LOCAL FUNCTIONS--------------------------

   -- Remove player chips
   local function remove_player_chips(player)
      if player.betChips then
         player.betChips:remove()
         player.betChips = nil
      end
   end
   
   -- Remove chips for all players
   local function remove_all_chips()
      for player, bet in pairs( ctrl:get_player_bets() ) do
         remove_player_chips(player)
      end
   end
   
   -- Add player chips
   local function add_player_chips(player)
      player.betChips = chipCollection()
      player.betChips.group.position = { MSCL[player.table_position][1] + 55, MSCL[player.table_position][2] }
      screen:add(player.betChips.group)
      player.betChips.group:raise_to_top()
   end
   
   -- Flip all cards up at the end of the hand
   local function all_cards_up()
      for _,card in pairs(allCards) do
         if not card.group.extra.face then
            flipCard(card.group)
         end
      end
   end
   
   -- Remove a player's hole cards
   local function remove_player_cards(player)
      local hole_cards = ctrl:get_hole_cards()
      local hole = hole_cards[player]
      for k,card in pairs(hole) do
         screen:remove(card.group)
      end
   end
   
   -- Animate all chips to center and add them to the pot
   local function animate_chips_to_center()
      for _, player in pairs( ctrl:get_players() ) do
         if player.betChips then
            player.betChips.group:animate{
               position = model.potchips.group.position,
               duration=500,
               mode="EASE_OUT_QUAD",
               on_completed = function()
                  model.potchips:set( model.potchips:value() + player.betChips:value() )
                  potText.text = model.potchips:value()
                  remove_player_chips(player)
               end
            }
         end
      end
   end
   
   ------------------------- GAME FLOW --------------------------
   
   -- Initialize stuff
   function pres:display_hand()
      
      -- Put community cards on the deck
      local cards = ctrl:get_community_cards()
      for i=5,1,-1 do
         cards[i].group.position = MCL.DECK
      end
      
      -- Put hole cards on the deck
      for player,hole in pairs( ctrl:get_hole_cards() ) do
         for _,card in pairs(hole) do
            card.group.position = MCL.DECK
            table.insert(allCards, card)
         end
         
         player.status:display()
         player.status:update( "I'm In" )  
      end
      
      -- Initialize SB and BB player chip collections
      local sb_player = model.players[ ctrl:get_sb_p() ]
      local bb_player = model.players[ ctrl:get_bb_p() ]
      add_player_chips( sb_player )
      add_player_chips( bb_player )
      sb_player.betChips:set( ctrl:get_sb_qty() )
      bb_player.betChips:set( ctrl:get_bb_qty() )
      
   end

   -- Deal hole cards
   function pres:deal_hole()
      
      for player,hole in pairs( ctrl:get_hole_cards() ) do
         
         local offset = 0
         local pos = {MPCL[player.table_position][1], MPCL[player.table_position][2]}
         
         for k,card in pairs(hole) do
            screen:add(card.group)
            -- Animate and flip the card if the player is human
            card.group:animate{x = pos[1] + offset, y = pos[2] + offset, mode=MODE, duration=TIME, on_completed = function() if player.isHuman then flipCard(card.group) end end }
            card.group:raise_to_top()
            offset = offset + 30
         end
      end
      
   end
   
   -- Deal community cards
   local function deal_cards(start, finish)
      local cards = ctrl:get_community_cards()
      for i=start,(finish or start) do
         cards[i].group:animate{ position = MCL[i], duration = TIME, mode = MODE, z_rotation=-3 + math.random(5), on_completed = function() flipCard(cards[i].group) end }
         screen:add(cards[i].group)
         print("NOW DEALING CARD", i)
         table.insert(allCards, cards[i])
      end
   end
   
   -- Animate chips and deal flop
   function pres:deal_flop()
      animate_chips_to_center()
      deal_cards(1, 3)
      print("ALLCARDS NOW CONTAINS", #allCards, "CARDS")
   end
   
   -- Animate chips and deal turn
   function pres:deal_turn()
      animate_chips_to_center()
      deal_cards(4)
      print("ALLCARDS NOW CONTAINS", #allCards, "CARDS")
   end
   
   -- Animate chips and deal river
   function pres:deal_river()
      animate_chips_to_center()
      deal_cards(5)
      print("ALLCARDS NOW CONTAINS", #allCards, "CARDS")
   end
   
   -- End of the game
   function pres.showdown(pres, winners, poker_hand)
      animate_chips_to_center()
      all_cards_up()
      print(poker_hand.name .. " passed to pres:showdown()")
      
      winners[1].status:update( poker_hand.name )
   end

   -- Clear everything
   function pres.clear_ui(pres)
   
      -- clear cards
      for i,card in ipairs(allCards) do
         print("Removing card", i)
         resetCardGroup(card.group)
         print(card.group.parent, screen, card.group.parent==screen)
         if card.group.parent == screen then screen:remove(card.group) end
         
      end
            
      print("ALLCARDS NOW CONTAINS", #allCards, "CARDS. THEY WILL NOW BE REMOVED")
      allCards = {}
      
      -- reset bets
      remove_all_chips()
   end
   
   -------------------------PLAYER TURNS--------------------------
   
   -- START
   -- This is the players turn, deal with dog animations and chips
   function pres:start_turn(player)
   
      if not player.betChips then add_player_chips(player) end
      assert(player.betChips)
   
      player.status:update( "My turn, foo!" )
      local pos = player.table_position
      local params = DOG_ANIMATIONS[ pos ]
      if params and params.name then
         a = Animation(params.dog, params.frames, params.position)
      end
      
      player.glow.opacity = 255
      
   end

   -- FOLD
   function pres:fold_player(player)
      remove_player_chips(player)
      remove_player_cards(player)
      player.status:hide()
      player.glow.opacity = 50
   end

   -- CALL
   function pres:call_player(player)
      local bet = ctrl:get_player_bets()[player]
      player.betChips:set(bet)
      player.status:update( "Call "..bet )
   end
   
   -- RAISE
   function pres:raise_player(player)
      local bet = ctrl:get_player_bets()[player]
      player.betChips:set(bet)
      player.status:update( "Raise to "..bet )
   end

   -- FINISH TURN
   function pres:finish_turn(player)
      player.glow.opacity = 0
   end

   -- SOMEONE LEFT A SEAT
   function pres:remove_player(removed_player)
      pres:fold_player(removed_player)
   end

   -- EVERYONE ELSE FOLDED
   function pres:win_from_bets(only_player)
   end
   
end)
