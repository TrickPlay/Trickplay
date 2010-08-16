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
end)