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

   function state.bet(state, round)
      local active_player = in_players[action]
      local fold, bet
      if false and active_player.isHuman then
         
      else
         -- get computer move
         -- current cards, bet to call, min raise, current wager, pot size
         assert(hole_cards[active_player])
         fold, bet = active_player:get_move(hole_cards[active_player], community_cards, position, call_bet, min_raise, player_bets[active_player], pot, round)
         if fold then
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
      end

      local continue = true

      assert(#in_players > 0)
      if #in_players == 1 then
         give_winner_pot_and_bone_out()
         return true
      end

      for i, player in ipairs(in_players) do
         if not done[player] then
            continue = false
         end
      end

      if continue then
         -- set the pot
         for i,player in ipairs(in_players) do
            pot = pot + player_bets[player]
            player_bets[player] = 0
            done[player] = false
         end

         -- reset the new action
         local tmp_action = (dealer % #players) + 1
         local safety_counter = 0
         while done[players[tmp_action]] == true do
            assert(safety_counter <= #players)
            tmp_action = (tmp_action % #players) + 1
            safety_counter = safety_counter+1
         end
         action = tmp_action
      else
         local tmp_action = (action % #players) + 1
         local safety_counter = 0
         while done[players[tmp_action]] == true do
            assert(safety_counter <= #players)
            tmp_action = (tmp_action % #players) + 1
            safety_counter = safety_counter+1
         end
         action = tmp_action
      end
      return continue
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
