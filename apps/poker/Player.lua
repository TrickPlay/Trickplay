Player = Class(function(player, args, ...)
   player.isHuman = false
   player.number = 0
   player.bet = model.bet.DEFAULT_BET
   player.money = 800
   player.position = false
   player.table_position = nil
   player.chipPosition = nil
   for k,v in pairs(args) do
      player[k] = v
   end
   
   --[[
   function player:createMoneyChips()
      
      player.moneyChips = chipCollection()
      player.moneyChips.group.position = {player.chipPosition[1], player.chipPosition[2]}
      player.moneyChips:set(player.money)
      player.moneyChips:arrange(55, 5)
      screen:add(player.moneyChips.group)
      
   end
   --]]
   
   function player:createBetChips()
      
      player.betChips = chipCollection()
      player.betChips.group.position = {player.chipPosition[1], player.chipPosition[2]}
      player.betChips:set(player.bet)
      player.betChips:arrange(55, 5)
      screen:add(player.betChips.group)
      
   end

   --[[
      @return The Player's current position. Early, Middle, Late,...
      view Position table in Globals.lua for options
   --]]
   function player:get_position(state)
      -- TODO: actually calculate position
      return Position.BIG_BLIND
   end

   ---
   -- @param hole an array of two hole cards
   -- @param community_cards
   -- @param call_bet the bet you need to make in order to call
   -- @param position  early, middle, late, whatever
   -- @param min_raise the minimum raise, so values of bet between
   -- call_bet+1 and call_bet+min_raise-1 are invalid
   -- @param current_bet the size of the bet currently in front of the
   -- player for the betting round
   -- @param pot current size of pot
   -- @param round
   -- @returns fold boolean  true if player should fold
   -- @returns bet number  quantity of bet, if fold then bet should be 0
   --function player:get_move(hole, community_cards, position, call_bet, min_raise, current_bet, pot, round)
   function player:get_move(state)
      
      local hole = state:get_hole_cards()[self]
      local position = self:get_position(state)
      local fold = false
      local call_bet = state:get_call_bet()
      local min_raise = state:get_min_raise()
      local round = Rounds.HOLE
      local raisedFactor = RaiseFactor.UR
      local community_cards = state:get_community_cards()
      -- move the ai will make
      local ai_move = Moves.FOLD
      local amount_to_raise = RaiseFactor.RR

      --combine the community cards and hole
      assert(hole[1])
      assert(hole[2])
      local all_cards = {}
      all_cards[1], all_cards[2] = hole[1], hole[2]
      for i,v in ipairs(community_cards) do
          table.insert(all_cards, v)
      end
      local best_hand = get_best(all_cards)

      hand_print(hole)
      hand_print(community_cards)
      
      -- get outs for enemy cards winning
      local outs = 0
      local total_outs = 0

      -- @return some_outs Gets outs of hands that will beat the player
      -- @return some_total_outs Total outs for all hands of the enemies
      local function get_outs(i, j, k, l)
         local some_outs = 0
         local some_total_outs
         local a_hand = {}
         a_hand[1] = community_cards[i]
         a_hand[2] = community_cards[j]
         a_hand[3] = community_cards[k]
         if(l) then
            a_hand[4] = community_cards[l]
         end
         out_table = count_outs(a_hand)
         for place,poker_hand in ipairs(PokerHands) do
            if(place <= best_hand) then
               some_outs = some_outs + out_table[poker_hand]
            end
            some_total_outs = some_total_outs + out_table[poker_hand]
         end
         return some_outs, some_total_outs
      end

      local function curvature(a_move)
         if(a_move == Moves.CALL) then
            if(3 == math.random(3)) then
               a_move = Moves.RAISE
            end
         elseif(ai_move == Moves.RAISE) then
            if(3 == math.random(3)) then
               a_move = Moves.CALL
            end
         end            
         return a_move, math.random(RaiseFactor.R, RaiseFactor.RR)
      end

      local playsTable = {
         [Rounds.HOLE] = function(a_move)
            -- TODO: get a calculation or param that determines whether
            --       the bets have been unraised, raised, or re-raised
            local hand = sort_hand(hole)
            local suit = UNSUITED
            if(hand[1].suit.name == hand[2].suit.name) then
               suit = SUITED
            end

            a_move = preFlopLUT[position][raisedFactor][hand[1].rank.num][hand[2].rank.num][suit]
            --introduce a random element
            if(math.random(4) == 4) then
               a_move = math.random(Moves.CALL, Moves.FOLD)
            end
            return a_move, math.random(RaiseFactor.R, RaiseFactor.RR)
         end,
         [Rounds.FLOP] = function(a_move)
            --First, check to see that the best hand is not the
            --river
            for place,poker_hand in ipairs(PokerHands) do
               if(poker_hand.present_in(community_cards)) and
                (place >= best_hand) then
                  return Moves.FOLD
               end
            end

            -- TODO: Un-Fugly this code
            --get the outs in 3 card combos of the river and compare
            --against the player's best hand
            local i = 1
            local j = 2
            local k = 3
            while(k <= #community_cards) do
               local some_outs, some_total_outs = get_outs(i,j,k)
               outs = outs + some_outs
               total_outs = total_outs + some_total_outs
               k = k + 1
            end
            while(j <= #community_cards - 1) do
               local some_outs, some_total_outs = get_outs(i,j,k)
               outs = outs + some_outs
               total_outs = total_outs + some_total_outs
               j = j + 1
            end
            while(i <= #community_cards - 2) do
               local some_outs, some_total_outs = get_outs(i,j,k)
               outs = outs + some_outs
               total_outs = total_outs + some_total_outs
               i = i + 1
            end

            local losing_odds = outs/total_outs
            if(losing_odds > HIGH_OUTS_RANGE) then
               return Moves.FOLD
            elseif(losing_odds <= HIGH_OUTS_RANGE and
            losing_odds >= LOW_OUTS_RANGE) then
               return Moves.CALL
            elseif(outs/total_outs < LOW_OUTS_RANGE) then
               outs = 0
               total_outs = 0
               --get the outs in 4 card combos of the river and compare
               --against the player's best hand
               i = 1
               j = 2
               k = 3
               local l = 4
               while(l <= #community_cards) do
                  local some_outs, some_total_outs = get_outs(i,j,k,l)
                  outs = outs + some_outs
                  total_outs = total_outs + some_total_outs
                  l = l + 1
               end
               while(k <= #community_cards - 1) do
                  local some_outs, some_total_outs = get_outs(i,j,k,l)
                  outs = outs + some_outs
                  total_outs = total_outs + some_total_outs
                  k = k + 1
               end
               while(j <= #community_cards - 2) do
                  local some_outs, some_total_outs = get_outs(i,j,k,l)
                  outs = outs + some_outs
                  total_outs = total_outs + some_total_outs
                  j = j + 1
               end
               while(i <= #community_cards - 3) do
                  local some_outs, some_total_outs = get_outs(i,j,k,l)
                  outs = outs + some_outs
                  total_outs = total_outs + some_total_outs
                  i = i + 1
               end
               local losing_odds = outs/total_outs
               if(losing_odds > HIGH_OUTS_RANGE) then
                  return Moves.FOLD
               elseif(losing_odds <= HIGH_OUTS_RANGE and
               losing_odds >= LOW_OUTS_RANGE) then
                  return Moves.RAISE, RaiseFactor.R
               elseif(outs/total_outs < LOW_OUTS_RANGE) then
                  return Moves.RAISE, RaiseFactor.RR
               else
                   error("problem ai betting")
               end
            else
               error("problem ai betting")
            end
         end,
         [Rounds.TURN] = function(a_move)
            return curvature(a_move)
         end,
         [Rounds.RIVER] = function(a_move)
            return curvature(a_move)
         end
      }

      ai_move, amount_to_raise = playsTable[round](ai_move)
      
      if(Moves.CALL == ai_move) then
         print("\nCALL, call_bet = "..call_bet.."\n")
         return false, call_bet
      elseif(Moves.FOLD == ai_move) then
         print("\nFOLD\n")
         return true, 0
      elseif(Moves.RAISE == ai_move) then
         if(amount_to_raise == RaiseFactor.R) then
            local a_bet = math.random(call_bet+min_raise, call_bet*2)
            if(a_bet > player.money) then
               a_bet = player.money
            end
            print("\nRAISE, raised by "..a_bet.."\n")
            return false, a_bet
         elseif(amount_to_raise == RaiseFactor.RR) then
            local a_bet = math.random(call_bet*1.5+min_raise, call_bet*2.5)
            if(a_bet > player.money) then
               a_bet = player.money
            end
            print("\nRAISE, raised by "..a_bet.."\n")
            return false, a_bet
         else
            error("failed raising the steaks")
         end
      else
         error("someth'n wrong with the moves")
      end
   end
   
   player.status = PlayerStatusView(model, nil, player)
   player.status:initialize()
   assert(player.status)

end)
