Player = Class(function(player, args, ...)
   player.isHuman = false
   player.number = 0
   player.bet = model.bet.DEFAULT_BET
   player.money = INITIAL_ENDOWMENT
   player.position = false
   player.table_position = nil
   player.chipPosition = nil
   player.difficulty = Difficulty.EASY
   for k,v in pairs(args) do
      player[k] = v
   end
   
   player.glow = DOG_GLOW[ player.table_position ]
   
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

   function player:get_position(state)
      
      local num_of_players = 0
      for _,__ in ipairs(state:get_players()) do
         num_of_players = num_of_players + 1
      end

      local active_player = state:get_active_player()
      local action_player = 0
      for i,v in ipairs(state:get_players()) do
         if(active_player == v) then
            action_player = i
         end
      end
      assert(action_player > 0)
      assert(action_player <= num_of_players)

      --eliminate obvious cases
      if(action_player == state:get_sb_p()) then
         return Position.SMALL_BLIND
      elseif(action_player == state:get_bb_p()) then
         return Position.BIG_BLIND
      elseif(action_player == state:get_dealer()) then
         return Position.LATE
      else
      --other cases
         local position = action_player - state:get_bb_p()
         if(position < 0) then
            position = position + num_of_players
         end
         --edge case
         if(num_of_players == 5) then
            position = position + 1
         end
         assert(position < Position.LATE)
         return position
      end
      error("error calculation position")
   end

   local function calculate_bet(call_bet, min_raise, stddev, ai_move, amount_to_raise, best_hand, orig_bet)

      assert(call_bet >= 0)
      assert(min_raise > 0)
      assert(stddev)
      assert(ai_move)
      assert(amount_to_raise)
      assert(best_hand)
      -- first figure out if the bet is too high for the player
      local a_bet = call_bet+min_raise
      local random_seed = 3^(-(a_bet/player.money))+.1+stddev --use a power function for scaling

      local coef_of_chance = 13-best_hand+player.difficulty
      print("coef_of_chance: "..coef_of_chance)
      print("random_seed: "..random_seed)
      local m = math.floor(random_seed*coef_of_chance)
      assert(m >= 1, "math.floor(random_seed*coef_of_chance) was too small: " .. m)
      local num = math.random(m)
      print("num: "..num.."\n")
      if(num == 1) then
         print("\nFOLD\n")
         return true, 0
      -- if the bet wont destroy the player's account then he's good to raise
      elseif(Moves.CALL == ai_move) then
         print("\nCALL, call_bet = "..call_bet.."\n")
         -- only call if really financially feasible
         if(call_bet < (.3+stddev)*player.money) then
            return false, call_bet
         else
            print("\nFOLD\n")
            return true, 0
         end
      elseif Moves.RAISE == ai_move then
         assert(call_bet >= 0)
         assert(min_raise > 0)
         local a_bet = call_bet+min_raise
         if amount_to_raise == RaiseFactor.R then
            --websites say raising the bet times 2 is a good standard?
            if a_bet < call_bet*2 then
               a_bet = math.random(a_bet, call_bet*2)
            end
            if a_bet > player.money+orig_bet then
               a_bet = player.money+orig_bet
            end
            print("\nRAISE, raised to "..a_bet.." while call_bet is "..call_bet.."\n")
            return false, a_bet
         elseif amount_to_raise == RaiseFactor.RR then
            if(call_bet*2+min_raise < call_bet*3) then
               a_bet = math.random(call_bet*2+min_raise, call_bet*3)
            end
            if a_bet > player.money+orig_bet then
               a_bet = player.money+orig_bet
            end
            print("\nRAISE, raised to "..a_bet.." while call_bet is "..call_bet.."\n")
            return false, a_bet
         else
            error("failed raising the steaks")
         end
      else
         error("someth'n wrong with the moves")
      end

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
   local last_move = Moves.FOLD
   function player:get_move(state)
      -- stuff that the player usually plays off of
      local hole = state:get_hole_cards()[self]
      local position = self:get_position(state)
      local fold = false
      local call_bet = state:get_call_bet()
      local min_raise = state:get_min_raise()
      local round = state:get_round()
      print("\nRound: "..round.."\n")
      local raisedFactor = RaiseFactor.UR
      local community_cards = state:get_community_cards()
      local orig_bet = state:get_orig_bet()
      -- move the ai will make
      local ai_move = last_move
      local amount_to_raise = RaiseFactor.RR

      print("player calculates call bet is " .. call_bet .. " and min_raise is " .. min_raise)
      -- combine the community cards and hole
      assert(hole[1])
      assert(hole[2])
      local all_cards = {}
      all_cards[1], all_cards[2] = hole[1], hole[2]
      for i,v in ipairs(community_cards) do
          table.insert(all_cards, v)
      end
      local _, best_hand = get_best(all_cards)

      -- arbitrary random factor
      local stddev = (math.random(self.difficulty)-1) * .2

      hand_print(hole)
      hand_print(community_cards)
      
      -- get outs for enemy cards winning
      local outs = 0
      local total_outs = 0

      -- @return some_outs Gets outs of hands that will beat the player
      -- @return some_total_outs Total outs for all hands of the enemies
      local function get_outs(i, j, k, l)
         local some_outs = 0
         local some_total_outs = 0
         local a_hand = {}
         a_hand[1] = community_cards[i]
         a_hand[2] = community_cards[j]
         a_hand[3] = community_cards[k]
         if(l) then
            a_hand[4] = community_cards[l]
         end
         local out_table = count_outs(a_hand)
         for place,poker_hand in ipairs(PokerHands) do
            if(out_table[poker_hand]) then
               if(place <= best_hand) then
                  some_outs = some_outs + out_table[poker_hand]
               end
               some_total_outs = some_total_outs + out_table[poker_hand]
            end
         end
         return some_outs, some_total_outs
      end

      local function curvature(a_move)
         if(a_move == Moves.CALL) then
            if(4 <= math.random(3) + self.difficulty) then
               a_move = Moves.RAISE
            end
         elseif(ai_move == Moves.RAISE) then
            if(4 <= math.random(3) + self.difficulty) then
               a_move = Moves.CALL
            end
         end
         return a_move, math.random(RaiseFactor.R, RaiseFactor.RR)
      end

      local playsTable = {
         [Rounds.HOLE] = function(a_move)
            -- TODO: get a calculation or param that determines whether
            --       the bets have been unraised, raised, or re-raised
            local hand = hole
            if(hand[1].rank.num < hand[2].rank.num) then
                hand[1], hand[2] = hand[2], hand[1]
            end
            local suit = UNSUITED
            if(hand[1].suit.name == hand[2].suit.name) then
               suit = SUITED
            end

            a_move = preFlopLUT[position][raisedFactor][hand[1].rank.num][hand[2].rank.num][suit]
            print("\nposition = "..position.."\nraisedFactor = "..raisedFactor.."\nhand[1].rank.num = "..hand[1].rank.num.."\nhand[2].rank.num = "..hand[2].rank.num.."\n")
            --introduce a random element
            if(5 <= math.random(4) + self.difficulty) then
               a_move = math.random(Moves.CALL, Moves.RAISE)
               print("\nrandomize move\n")
            end
            return a_move, math.random(RaiseFactor.R, RaiseFactor.RR)
         end,
         [Rounds.FLOP] = function(a_move)
            --First, check to see that the best hand is not the
            --river
            for place,poker_hand in ipairs(PokerHands) do
               if(poker_hand.present_in(community_cards)) and
                (place <= best_hand) then
                  print("place = "..place)
                  print("best_hand = "..best_hand)
                  --if player's hand is a high pair or higher its still
                  --worth playing even though a pair is in the river:
                  if(best_hand == PokerHands.ONE_PAIR) and
                   (hole[1].rank.num > 9) then
                     return Moves.CALL, RaiseFactor.UR
                  else
                     return Moves.FOLD, RaiseFactor.UR
                  end
               end
            end
            print("best_hand = "..best_hand)

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
            k = k - 1
            while(j <= #community_cards - 1) do
               local some_outs, some_total_outs = get_outs(i,j,k)
               outs = outs + some_outs
               total_outs = total_outs + some_total_outs
               j = j + 1
            end
            j = j - 1
            while(i <= #community_cards - 2) do
               local some_outs, some_total_outs = get_outs(i,j,k)
               outs = outs + some_outs
               total_outs = total_outs + some_total_outs
               i = i + 1
            end
            print("outs = "..outs)
            print("total_outs = "..total_outs)
            local losing_odds = outs/total_outs
            print("\nlosing_odds1 = "..losing_odds.."\n")
            if(losing_odds > HIGH_OUTS_RANGE + stddev) then
               -- if player's hand is a high pair or higher its still
               -- worth playing even though a pair is in the river:
               if(best_hand == PokerHands.ONE_PAIR) and
                (hole[1].rank.num > 9) then
                  return Moves.CALL, RaiseFactor.UR
               else
                  return Moves.FOLD, RaiseFactor.UR
               end
            elseif(losing_odds <= HIGH_OUTS_RANGE + stddev) and
            (losing_odds >= LOW_OUTS_RANGE) then
               return Moves.CALL, RaiseFactor.UR
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
               l = l - 1
               while(k <= #community_cards - 1) do
                  local some_outs, some_total_outs = get_outs(i,j,k,l)
                  outs = outs + some_outs
                  total_outs = total_outs + some_total_outs
                  k = k + 1
               end
               k = k - 1
               while(j <= #community_cards - 2) do
                  local some_outs, some_total_outs = get_outs(i,j,k,l)
                  outs = outs + some_outs
                  total_outs = total_outs + some_total_outs
                  j = j + 1
               end
               j = j - 1
               while(i <= #community_cards - 3) do
                  local some_outs, some_total_outs = get_outs(i,j,k,l)
                  outs = outs + some_outs
                  total_outs = total_outs + some_total_outs
                  i = i + 1
               end

               print("outs = "..outs)
               print("total_outs = "..total_outs)
               losing_odds = outs/total_outs
               print("\nlosing_odds2 = "..losing_odds.."\n")
               if(losing_odds > HIGH_OUTS_RANGE + stddev) then
                  return Moves.CALL, RaiseFactor.UR
               elseif(losing_odds <= HIGH_OUTS_RANGE + stddev) and
               (losing_odds >= LOW_OUTS_RANGE) then
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
      last_move = ai_move
      
      if Moves.FOLD == ai_move then
         print("\nFOLD\n")
         return true, 0
      else
         return calculate_bet(call_bet, min_raise, stddev, ai_move, amount_to_raise, best_hand, orig_bet)
      end

   end
   
   player.status = PlayerStatusView(model, nil, player)
   player.status:initialize()
   assert(player.status)
   
   --function player:get_move(state)
   --   local call_bet = state:get_call_bet()
   --   return false, call_bet
   --end

end)
