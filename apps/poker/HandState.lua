HandState = Class(nil, function(state, ctrl, ...)
   local ctrl = ctrl or error("No hand control passed to HandState")
   local community_cards
   local hole_cards
   local player_bets
   local pot
   local action

   local players
   local sb_qty
   local bb_qty
   local dealer
   local sb_p
   local bb_p
   local deck
   local in_players

   -- array of players who are still in the game.
   local in_players
   -- index of active player in players table.. it should be the case that players[players_action] == in_players[action]
   local players_action
   -- player => done table. if done[player] then player is in the hand, but doesn't need to bet anymore
   local done
   -- player => removed table.
   local removed
   local call_bet
   local min_raise

   function state:get_community_cards() return community_cards end
   function state:get_hole_cards() return hole_cards end
   function state:get_player_bets() return player_bets end
   function state:get_pot() return pot end
   function state:get_action() return action end
   function state:get_dealer() return dealer end
   function state:get_players() return players end
   function state:get_in_players() return in_players end
   function state:get_active_player() return in_players[action] end
   function state:get_sb_qty() return sb_qty end
   function state:get_bb_qty() return bb_qty end
   function state:get_dealer() return dealer end
   function state:get_sb_p() return sb_p end
   function state:get_bb_p() return bb_p end
   function state:get_deck() return deck end
   function state:get_call_bet() return call_bet end
   function state:get_min_raise() return min_raise end
   function state:get_round() return ctrl:get_round() end
   function state:player_done() return done[in_players[action]] end

   function state.initialize(state, args)
      players = args.players
      sb_qty = args.sb_qty
      bb_qty = args.bb_qty
      dealer = args.dealer
      sb_p = args.sb_p
      bb_p = args.bb_p
      deck = args.deck
      round = Rounds.HOLE

      in_players = {}
      
      done = {}
      removed = {}
      for i, player in ipairs(players) do
         in_players[i] = player
         done[player] = false
         removed[player] = false
      end

      -- person after the big blind goes first, initially
      action = (bb_p % #players) + 1
      players_action = action
      -- initialize bet in front of each player
      player_bets = {}
      for _,player in ipairs(players) do
         player_bets[player] = 0
      end
      pot = 0

      -- initialize small blind, big blind bets
      player_bets[players[sb_p]] = sb_qty
      players[sb_p].money = players[sb_p].money - sb_qty
      player_bets[players[bb_p]] = bb_qty
      players[bb_p].money = players[bb_p].money - bb_qty
      print("the small blind player has $" .. players[sb_p].money)
      print("the big blind player has $" .. players[bb_p].money)

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

   function state.give_winner_pot(state)
      assert(#in_players == 1)
      local winner = in_players[1]
      for _,player in ipairs(players) do
         assert(done[player])
         if player ~= winner then
            assert(player_bets[player] == 0)
         end
      end
      winner.money = winner.money + player_bets[winner] + pot
      player_bets[winner] = 0
      pot = 0
   end

   local function set_bet_listener(callback, player)
      ctrl:set_bet_listener(callback, player)
   end

   -- if bet is less than call_bet then assume folding
   function state:execute_bet(fold, bet)
      print("HandState:execute_bet(" .. tostring(fold) .. ", " .. tostring(bet) .. ")")
      if type(fold) ~= "boolean" or type(bet) ~= "number" then
         error("execute_bet called with parameters of incorrect type", 2)
      end
      local active_player = in_players[action]
      print("active_player.number", active_player.number)
      if fold then
         print("\n\n\nplayer folded, " .. player_bets[active_player] .. " goes into the pot, player is left with $" .. active_player.money)
         -- current wager goes into pot
         pot = pot + player_bets[active_player]
         player_bets[active_player] = 0
         table.remove(in_players, action)
         
         removed[active_player] = true
         action = ((action - 1) % #in_players) + 1
         local next_players_action = (players_action % #players) + 1
         while removed[players[next_players_action]] do
            next_players_action = (next_players_action % #players) + 1
         end
         players_action = next_players_action
         ctrl:fold_player(active_player)
      else
         local max_bet = 0
         local cand
         for _,player in ipairs(in_players) do
            cand = player_bets[player] + player.money
            if cand > max_bet then max_bet = cand end
         end
         assert(bet <= max_bet, "bet was too large: bet was " .. bet .. " but max_bet was " .. max_bet)

         print("bet went from",player_bets[active_player],"to",bet)
         local delta = bet-player_bets[active_player]
         assert(0 <= delta, "player tried to decrease his bet from " .. player_bets[active_player] .. " to " .. bet)
         player_bets[active_player] = bet

         print("call_bet",call_bet,"min_raise",min_raise)
         -- bet is a call
         if bet < call_bet then
            print("player should have pushed all in")
            assert(
               active_player.money == 0,
               "if bet is less than the minimum bet to call, and player didn't fold, then player should be all in\n" ..
                  "but he had " .. active_player.money .. " leftover when he bet " .. bet .. " and the call bet was " .. call_bet
            )
         elseif bet == call_bet then
            print("player called")
         else
            print("player raised")
            assert(bet >= call_bet+min_raise or active_player.money == 0)
            if bet-call_bet > min_raise then
               min_raise = bet-call_bet
            end
            call_bet = bet
            for i,player in ipairs(in_players) do
               if i ~= action and player.money > 0 then
                  done[player] = false
               end
            end
         end
--         assert(0 <= delta and delta <= active_player.money) logic is kind of in bettingview/controller
         --active_player.money = active_player.money - delta
         ctrl:bet_player(active_player)
      end
      done[active_player] = true

      local continue = true

      assert(#in_players > 0)
      if #in_players == 1 then
         done[in_players[1]] = true
         ctrl:give_winner_pot_and_bone_out()
         return true
      end

      for i, player in ipairs(in_players) do
         if not done[player] then
            continue = false
         end
      end

      if continue then
         print("betting round finished, should go to the next one")

         -- set the pot
         for i,player in ipairs(in_players) do
            pot = pot + player_bets[player]
            player_bets[player] = 0
            done[player] = false
         end
         call_bet = 0
         min_raise = bb_qty

         -- reset the new action
         local tmp_action = (dealer % #in_players) + 1
         local safety_counter = 0
         while done[in_players[tmp_action]] == true do
            assert(safety_counter <= #in_players)
            tmp_action = (tmp_action % #in_players) + 1
            safety_counter = safety_counter+1
         end
         action = tmp_action
      else
         local tmp_action = (action % #in_players) + 1
         local safety_counter = 0
         while done[in_players[tmp_action]] == true do
            assert(safety_counter <= #in_players)
            tmp_action = (tmp_action % #in_players) + 1
            safety_counter = safety_counter+1
         end
         action = tmp_action
      end
      assert(action <= #in_players)
      return continue
   end

   function state.wait_for_bet(state, round)
      local continue = true

      -- this code shouldn't be here, it's just safety code.
      assert(#in_players > 0)
      if #in_players == 1 then
         done[in_players[1]] = true
         ctrl:give_winner_pot_and_bone_out()
         return true
      end

      for i, player in ipairs(in_players) do
         if not done[player] then
            continue = false
         end
      end
      if continue then return true end

      local active_player = in_players[action]
      if active_player.isHuman then
         model.currentPlayer = active_player
         model.in_players = in_players
         model:set_active_component(Components.PLAYER_BETTING)
         model:get_active_controller():set_callback(
            function(fold, bet)
               enable_event_listener(
                  TimerEvent{
                     interval=.1,
                     cb=function() execute_bet(fold, bet) end
                  })
            end)
         enable_event_listener(KbdEvent())
      else
         local fold, bet = active_player:get_move(hole_cards[active_player], community_cards, position, call_bet, min_raise, player_bets[active_player], pot, round)
         enable_event_listener(
            TimerEvent{
               interval=.5,
               cb=function()
                     execute_bet(fold, bet)
                     enable_event_listener(TimerEvent{interval=.1})
                  end})
      end
   end

   function state.bet(state, round)
      local active_player = in_players[action]
      assert(active_player)
      local fold, bet
      if false and active_player.isHuman then
         
      else
         -- get computer move
         -- current cards, bet to call, min raise, current wager, pot size
         fold, bet = active_player:get_move(hole_cards[active_player], community_cards, position, call_bet, min_raise, player_bets[active_player], pot, round)
      end

   end

   function state.showdown(state)
      assert(#in_players > 1)
      local in_hands = {}
      for _, player in ipairs(in_players) do
         local hand = {}
         for _, card in ipairs(hole_cards[player]) do
            table.insert(hand, card)
         end
         for _, card in ipairs(community_cards) do
            table.insert(hand, card)
         end
         in_hands[player] = hand
      end

      local best = in_players[1]
      local winners = {in_players[1]}
      local result, tmp_poker_hand, poker_hand

      for i=2,#in_players do
         result, tmp_poker_hand = compare_hands(in_hands[best], in_hands[in_players[i]])
         if not poker_hand then
            poker_hand = tmp_poker_hand
         end
         if result == 0 then
            table.insert(winners, in_players[i])
         elseif result == 1 then
            best = in_players[i]
            winners = {in_players[i]}
            poker_hand = tmp_poker_hand
         end
         if #in_players == 2 then
            poker_hand = tmp_poker_hand
         end
      end

      best.money = best.money + pot
      pot = 0

      print("player won with")
      for _, card in ipairs(in_hands[best]) do
         print(card.name)
      end
      print("won with " .. poker_hand.name .. " in state.showdown()")
      return winners, poker_hand
   end

end)
