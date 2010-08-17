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
   -- player => done table. if done[player] then 
   local done
   local call_bet
   local min_raise

   function state:get_community_cards() return community_cards end
   function state:get_hole_cards() return hole_cards end
   function state:get_player_bets() return player_bets end
   function state:get_pot() return pot end
   function state:get_action() return action end
   function state:get_players() return players end
   function state:get_in_players() return in_players end
   function state:get_active_player() return in_players[action] end
   function state:get_sb_qty() return sb_qty end
   function state:get_bb_qty() return bb_qty end
   function state:get_sb_p() return sb_p end
   function state:get_bb_p() return bb_p end
   function state:get_deck() return deck end

   function state.initialize(state, args)
      players = args.players
      sb_qty = args.sb_qty
      bb_qty = args.bb_qty
      dealer = args.dealer
      sb_p = args.sb_p
      bb_p = args.bb_p
      deck = args.deck

      in_players = {}
      done = {}
      for i, player in ipairs(players) do
         in_players[i] = player
         done[player] = false
      end

      -- person after the big blind goes first, initially
      action = (bb_p % #players) + 1

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


   function state:execute_bet(bet)
      local active_player = in_players[action]
      if bet == 0 then
         -- current wager goes into pot
         pot = pot + player_bets[active_player]
         player_bets[active_player] = 0
         table.remove(in_players, action)
         action = ((action - 1) % #in_players) + 1
         ctrl:fold_player(active_player)
      else
         local delta = bet-player_bets[active_player]
         assert(0 <= delta and delta <= active_player.money)
         player_bets[active_player] = bet
         active_player.money = active_player.money - delta
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
         model:get_active_controller():set_callback(function(fold, bet) execute_bet(fold, bet) end)
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