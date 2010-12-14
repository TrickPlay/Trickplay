HandState = Class(nil,function(state, ctrl, ...)
   local ctrl = ctrl or error("No hand control passed to HandState")
   local community_cards
   local hole_cards
   local player_bets
   local pot
   local pots
   local current_pot
   local action

   local players
   local sb_qty
   local bb_qty
   local dealer
   local sb_p
   local bb_p
   local deck
   local in_players
   local final_hands

   -- index of active player in players table.. it should be the case that players[players_action] == in_players[action]
   local players_action
   -- player => done table. if done[player] then player is in the hand, but doesn't need to bet anymore
   local done
   -- player => removed table.
   local out
   local call_bet
   local min_raise
   local num_inplayers
   local all_in
   local orig_money

   function state:get_community_cards() return community_cards end
   function state:get_hole_cards() return hole_cards end
   function state:get_player_bets() return player_bets end
   function state:get_pot() return pot end
   function state:get_pots() return pots end
   function state:get_active_player_bet() return player_bets(players[action]) end
   function state:get_action()
      local in_players = state:get_in_players()
      local active_player = state:get_active_player()
      for i,player in ipairs(in_players) do
         if active_player == player then
            return i
         end
      end
   end
   function state:get_dealer() return dealer end
   function state:get_players() return players end
   function state:get_in_players()
      local in_players = {}
      for _,player in ipairs(players) do
         if not out[player] then
            table.insert(in_players, player)
         end
      end
      return in_players
   end
   function state:get_in_hands()
      local in_players = state:get_in_players()
      assert(#in_players > 1)

      -- get all the players' hands
      local in_hands = {}
      for _, player in ipairs(in_players) do
         local hand = {}
         for _, card in ipairs(hole_cards[player]) do
            table.insert(hand, card)
         end
         for _, card in ipairs(community_cards) do
            table.insert(hand, card)
         end
         in_hands[player] = get_best_5(hand)
      end
      return in_hands
   end
   function state:get_final_hands() return final_hands end
   function state:get_orig_bet()
      return player_bets[state:get_active_player()]
   end
   function state:get_active_player() return players[action] end
   function state:get_sb_qty() return sb_qty end
   function state:get_bb_qty() return bb_qty end
   function state:get_dealer() return dealer end
   function state:get_sb_p() return sb_p end
   function state:get_bb_p() return bb_p end
   function state:get_deck() return deck end
   function state:get_call_bet() return call_bet end
   function state:get_min_raise() return min_raise end
   function state:get_round() return ctrl:get_round() end
   function state:player_done() return done[players[action]] end
   function state:get_out_table() return out end
   function state:get_max_bet()
      local top1 = 0
      local top2 = 0
      for _,player in ipairs(players) do
         if not out[player] then
            local holdings = player.money + player_bets[player]
            if holdings > top1 then top1, top2 = holdings, top1
            elseif holdings > top2 then top2 = holdings end
         end
      end
      return top2
   end

   --[[
      @return true if all players have finished betting, false otherwise
   --]]
   function state:get_bets_done()
      local num_all_in = 0
      local num_in_players = #state:get_in_players()
      print("num_in_players:",num_in_players)
      local all_in_bet = 0
      for _,player in ipairs(state:get_in_players()) do
         if player_bets[player] > all_in_bet then all_in_bet = player_bets[player] end
         if all_in[player] then
            num_all_in = num_all_in+1
         else
            not_all_in_player = player
         end
      end
      if num_all_in == num_in_players-1
       and player_bets[not_all_in_player] == all_in_bet
       or num_all_in == num_in_players then
         return true
      end

      return false
   end

   --[[
      Initializes the hand. Includes moving BB and SB and setting up each
      players Hole.
   --]]
   function state.initialize(state, args)
      players = args.players
      sb_qty = args.sb_qty
      bb_qty = args.bb_qty
      dealer = args.dealer
      sb_p = args.sb_p
      bb_p = args.bb_p
      deck = args.deck
      round = Rounds.HOLE

      done, out, all_in, orig_money = {}, {}, {}, {}
      for i, player in ipairs(players) do
         done[player] = false
         out[player] = false
         all_in[player] = false
         orig_money[player] = player.money
      end
      num_inplayers = #players
      ctrl:set_bets_done(false)

      -- person after the big blind goes first, initially
      action = (bb_p % #players) + 1
      players_action = action
      -- initialize bet in front of each player
      player_bets = {}
      for _,player in ipairs(players) do
         player_bets[player] = 0
      end
      pot = 0
      pots = {}
      current_pot = 1

      -- initialize small blind, big blind bets
      local sb_player = players[sb_p]
      if sb_player.money < sb_qty then
         sb_player.money, player_bets[sb_player] = 0, sb_player.money
      else
         sb_player.money, player_bets[sb_player] = sb_player.money-sb_qty, sb_qty
      end
      local bb_player = players[bb_p]
      if bb_player.money < bb_qty then
         bb_player.money, player_bets[bb_player] = 0, bb_player.money
      else
         bb_player.money, player_bets[bb_player] = bb_player.money-bb_qty, bb_qty
      end

      -- holds everyone's current money put into the pot
      running_money = {}
      for _, player in ipairs(players) do
         running_money[player] = player_bets[player]
      end

      call_bet = bb_qty
      min_raise = bb_qty

      -- initialize cards for each player
      deck:reset()
      deck:shuffle()
      hole_cards = {}
      for _,player in ipairs(players) do
         hole_cards[player] = deck:deal(2)
      end
      community_cards = deck:deal(5)
   end

   local function set_out(player)
      if not out[player] then
         num_inplayers = num_inplayers - 1
         out[player] = true
      end
   end

   local function get_num_inplayers()
      return num_inplayers
   end

   local function get_only_player()
      local only_player = nil
      for _,player in ipairs(players) do
         if not out[player] then
            if only_player then
               print("get_only_player called with more than one player left... returning a remaining player")
            end
            only_player = player
         end
      end
      return only_player
   end


   -- side pot stuff
   local function update_side_pot(active_player, bet)
      pots[current_pot].contributions[active_player] = bet
   end

   local function create_side_pot(bet)
      local quota = bet
      for _,pot in ipairs(pots) do
         quota = quota - pot.quota
      end
      pots[#pots].quota = quota
      table.insert(pots, {value = 0, contributions = {}, quota = 0})
   end

   local function balance_side_pots()
      for i,pot in ipairs(pots) do
         for player,contribution in pairs(pot.contributions) do
            if contribution > pot.quota and pot.quota > 0 then
               local diff = contribution - pot.quota
               pot.contributions[player] = pot.quota
               pots[i+1].contributions[player] = diff
            end
         end
      end

      current_pot = #pots
   end

   -- must guarentee in logic that winners[1] is the highest winner (overall best
   -- hand) or none of this will work!!!
   local function divide_side_pots(winners)
      for i,player in ipairs(winners) do
         -- if the player is a table of players you've got a split pot
         -- scenario as well
         if not player.is_a then
            local total = 0
            local the_player = player[1]
            for k,pot in ipairs(pots) do
               if pot.contributions[the_player] then
                  for a_player,contribution in pairs(pot.contributions) do
                     total = total + contribution
                     pot.contributions[a_player] = 0
                  end
               end
            end
            for j,a_player in ipairs(player) do
               a_player.money = a_player.money + math.floor(total/#player)
            end
         else
            local total = 0
            for j,pot in ipairs(pots) do
               if pot.contributions[player] then
                  for a_player,contribution in pairs(pot.contributions) do
                     total = total + contribution
                     pot.contributions[a_player] = 0
                  end
               end
            end
            player.money = player.money + total
         end
      end
   end

   ---
   -- Makes the active player take his turn. If fold is true, then player
   -- folded, otherwise, player bet changes to bet (may be a call or a
   -- raise). Assumes the active player's money (player.money) reflects
   -- his current holdings.
   function state:execute_bet(fold, bet)
      if not pots[current_pot] then
          pots[current_pot] = {
              value = pot,
              contributions = {},
              quota = 0
          }
      end

      print("state:execute_bet(" .. tostring(fold) .. ", " .. tostring(bet) .. ")")
      local active_player = players[action]
      local old_player_bet = player_bets[active_player]
      done[active_player] = true
      if active_player.money == 0 then
         all_in[active_player] = true
         create_side_pot(bet)
      end

      local delta = 0
      -- if the player folds, then he's out of the hand, and whatever bet he had goes into the pot
      if fold then
         set_out(active_player)
         pot, player_bets[active_player] = pot+player_bets[active_player], 0
         ctrl:fold_player(active_player)
         -- if he's out of money, then that's dumb.
         if active_player.money == 0 then
            table.remove(players, action)
            action = action - 1
         end

      -- player calls
      elseif bet == call_bet or (bet < call_bet and active_player.money == 0) then
         delta = bet - player_bets[active_player]
         player_bets[active_player] = bet
         -- specify the animation to be used
         if bet == 0 then
            ctrl:check_player(active_player)
         elseif active_player.money == 0 then
            ctrl:all_in_player(active_player)
         else
            ctrl:call_player(active_player)
         end

         update_side_pot(active_player, bet)

      -- player raises, forces everyone to act
      elseif bet >= call_bet+min_raise
      or (call_bet < bet and bet < call_bet+min_raise and active_player.money==0) then
         delta = bet - player_bets[active_player]
         player_bets[active_player] = bet
         for _, player in ipairs(players) do
            if player ~= active_player and not out[player] and not all_in[player] and player.money > 0 then
               done[player] = false
            end
         end

         -- set new call_bet and min_raise
         local overbid = bet-call_bet
         if overbid > min_raise then
            min_raise = overbid
         end
         call_bet = bet
         if active_player.money == 0 then
            ctrl:all_in_player(active_player)
         else
            ctrl:raise_player(active_player)
         end

         update_side_pot(active_player, bet)
      else
         error(
            "problem. this should never display. let's see what happened:" .. '\n' ..
               "call_bet: " .. call_bet .. ", min_raise: " .. min_raise ..'\n' ..
               "old bet: " .. old_player_bet .. ", new bet: " .. bet .. '\n' ..
               "player money: " .. active_player.money .. '\n'
         )
      end

    -------------- player finished bet, figure out next step ----------------

      running_money[active_player] = running_money[active_player] + delta
      local continue = true
      -- if only one player left then give him the pot and clean up
      if get_num_inplayers() == 1 then
         local only_player = get_only_player()
         only_player.money, player_bets[only_player], pot = only_player.money+player_bets[only_player]+pot,0,0
         ctrl:clear_pipeline()
         ctrl:win_from_bets(only_player)
         return continue 
      end

      -- if there are still in players who need to bet, then stay in betting round
      for i, player in ipairs(players) do
         if not out[player] and not done[player] and not all_in[player] then
            continue = false
         end
      end

      -- otherwise, betting round done, so...
      -- consolidate bets into the pot
      if continue then
         balance_side_pots()
         for i,player in ipairs(players) do
            pot, player_bets[player] = pot+player_bets[player], 0
            done[player] = false
         end
         call_bet = 0
         min_raise = bb_qty

         local tmp_action = (dealer % #players) + 1
         local safety_counter = 1
         local num_all_in = 0
         --print("before true loop")
         local num_in_players = #self:get_in_players()
         while out[players[tmp_action]]
         or done[players[tmp_action]] or all_in[players[tmp_action]] do
            if all_in[players[tmp_action]] then
               print("player "..tmp_action.." is all in")
               num_all_in = num_all_in+1
            end
            if num_all_in == num_in_players-1 then
               ctrl:set_bets_done(true)
               break
            end
            safety_counter = safety_counter + 1
            if safety_counter > #players then
               error("infinite loop detected in continue true")
               break
            end
            tmp_action = (tmp_action % #players) + 1
         end
         --print("after true loop")
         action = tmp_action
         ctrl:betting_round_over()
      else
         local tmp_action = (action % #players) + 1
         local safety_counter = 1
         local num_all_in = 0
         print("before false loop")
         local num_in_players = #self:get_in_players()
         -- rotate through the players to try and find the next available player to
         -- bet
         while out[players[tmp_action]] or done[players[tmp_action]] or all_in[players[tmp_action]] do
            if all_in[players[tmp_action]] then
               print("player "..tmp_action.." is all in")
               num_all_in = num_all_in+1
            end
            if num_all_in == num_in_players then
               ctrl:set_bets_done(true)
               break
            end
            safety_counter = safety_counter + 1
            if safety_counter > #players then
               error("infinite loop detected in continue false")
               break
            end
            tmp_action = (tmp_action % #players) + 1
         end
         action = tmp_action
      end
      return continue
   end

   local function remove_player(i)
      local removed_player = players[i]
      table.remove(players,i)
      out[removed_player] = nil
      done[removed_player] = nil
      player_bets[removed_player] = nil
      ctrl:remove_player(removed_player)
   end
   
   function state:remove_players()
      local i = 1
      while i <= #players do
         if players[i].money == 0 then
            remove_player(i)
         else
            i=i+1
         end
      end
   end

   function state.showdown(state)
      local in_players = state:get_in_players()
      assert(#in_players > 1)

      -- get all the players' hands
      local in_hands = state:get_in_hands()
      final_hands = {}

      local best = in_players[1]
      local winners = {in_players[1]}
      local result, tmp_poker_hand, poker_hand
      result, tmp_poker_hand = compare_hands(in_hands[best], in_hands[in_players[1]])
      final_hands[in_players[1]] = in_hands[in_players[1]]

      -- compare all hands
      for i=2,#in_players do
         result, tmp_poker_hand = compare_hands(in_hands[best], in_hands[in_players[i]])
         if not poker_hand then
            poker_hand = tmp_poker_hand
         end
         if result == 0 then
            table.insert(winners, in_players[i])
            final_hands[in_players[i]] = in_hands[in_players[i]]
         elseif result == 1 then
            best = in_players[i]
            winners = {in_players[i]}
            poker_hand = tmp_poker_hand
            final_hands = {}
            final_hands[in_players[i]] = in_hands[in_players[i]]
         end
         if #in_players == 2 then
            poker_hand = tmp_poker_hand
         end
      end

      local test_pot = 0
      for _,player in ipairs(players) do
         test_pot = test_pot + running_money[player]
      end
      if test_pot ~= pot then
         print("sum of runningmoney was " .. test_pot .. " but should be " .. pot)
      end

      print("splitting $" .. pot .. " pot " .. #winners .. " ways")
      for _,winner in ipairs(winners) do
         winner.money = winner.money + math.floor(pot/#winners)
      end
      pot = 0

      return winners, poker_hand
   end

end)
