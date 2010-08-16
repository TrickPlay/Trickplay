dofile("HandState.lua")
dofile("HandPresentation.lua")

HandControl = Class(nil,function(ctrl, game_ctrl, ...)
   local state = HandState(ctrl)
   local pres = HandPresentation(ctrl)
   local game_ctrl = game_ctrl or error("no game_ctrl",2)
--   local bet_ctrl = BettingControl(ctrl)

   local hand_pipeline = {}
   local orig_hand_pipeline = {
      function(ctrl) return ctrl:deal(Rounds.HOLE) end,
      function(ctrl) return ctrl:bet(Rounds.HOLE) end,
      function(ctrl) return ctrl:deal(Rounds.FLOP) end,
      function(ctrl) return ctrl:bet(Rounds.FLOP) end,
      function(ctrl) return ctrl:deal(Rounds.TURN) end,
      function(ctrl) return ctrl:bet(Rounds.TURN) end,
      function(ctrl) return ctrl:deal(Rounds.RIVER) end,
      function(ctrl) return ctrl:bet(Rounds.RIVER) end,
      function(ctrl) return ctrl:showdown() end
   }
   -- an initialized hand state looks like this:
   -- {
   --    -- first three cards are flop, then turn, then river
   --    comm_cards={card1,card2,card3,card4,card5},
   --    remaining_players={player1, player2, player3, player4},
   --    stacks={},
   --    dealer=2,
   --    small_blind=3,
   --    big_blind=4,
   --    sb_qty=1,
   --    bb_qty=2,
   --

   --    events={}
   -- }
   -- local hand_state = {}

   -- Hand variables
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
   local done
   local call_bet
   local min_raise

   function ctrl:get_community_cards() return community_cards end
   function ctrl:get_hole_cards() return hole_cards end
   function ctrl:get_player_bets() return player_bets end
   function ctrl:get_pot() return pot end
   function ctrl:get_action() return action end
   function ctrl:get_players() return players end
   function ctrl:get_sb_qty() return sb_qty end
   function ctrl:get_bb_qty() return bb_qty end
   function ctrl:get_sb_p() return sb_p end
   function ctrl:get_bb_p() return bb_p end
   function ctrl:get_deck() return deck end

   -- private functions
   local function give_winner_pot_and_bone_out()
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
      hand_pipeline = {}
      enable_event_listener(Events.TIMER, 1)
   end

   -- public functions
   function ctrl.initialize(ctrl)
      state:initialize{
         players = game_ctrl:get_players(),
         sb_qty = game_ctrl:get_sb_qty(),
         bb_qty = game_ctrl:get_bb_qty(),
         dealer = game_ctrl:get_dealer(),
         sb_p = game_ctrl:get_sb_p(),
         bb_p = game_ctrl:get_bb_p(),
         deck = game_ctrl:get_deck()
      }

         players = game_ctrl:get_players()
         sb_qty = game_ctrl:get_sb_qty()
         bb_qty = game_ctrl:get_bb_qty()
         dealer = game_ctrl:get_dealer()
         sb_p = game_ctrl:get_sb_p()
         bb_p = game_ctrl:get_bb_p()
         deck = game_ctrl:get_deck()
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

      hand_pipeline = {}
      for _,stage in ipairs(orig_hand_pipeline) do
         table.insert(hand_pipeline, stage)
      end

      pres:display_hand()

      enable_event_listener(Events.TIMER, 1)
   end


   -- Table of ui deal animations
   local deal_LUT = {
      [Rounds.HOLE]=function(pres) pres:deal_hole() end,
      [Rounds.FLOP]=function(pres) pres:deal_flop() end,
      [Rounds.TURN]=function(pres) pres:deal_turn() end,
      [Rounds.RIVER]=function(pres) pres:deal_river() end
   }
   function ctrl.deal(ctrl, round)
      deal_LUT[round](pres)
      enable_event_listener(Events.TIMER, .5)
      return true
   end


   -- Handle betting stage of a hand.
   -- preconditions: active player 
   --
   -- postconditions: action var indexes current active player. also,
   -- proper event listener set up. if current active player is a
   -- human, then event listener waits for on_event call from 
   function ctrl.bet(ctrl, round)
      print(action)
      local active_player = in_players[action]
      local fold, bet
      if false and active_player.isHuman then
         
      else
         -- get computer move
         -- current cards, bet to call, min raise, current wager, pot size
         fold, bet = active_player:get_move(hole_cards[active_player], community_cards, position, call_bet, min_raise, player_bets[active_player], pot, round)
         if fold then
            -- current wager goes into pot
            pot = pot + player_bets[active_player]
            player_bets[active_player] = 0
            table.remove(in_players, action)
            action = ((action - 1) % #in_players) + 1
            pres:fold_player(active_player)
         else
            local delta = bet-player_bets[active_player]
            assert(0 <= delta and delta <= active_player.money)
            player_bets[active_player] = bet
            active_player.money = active_player.money - delta
            pres:bet_player(active_player)
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
      enable_event_listener(Events.TIMER, 1)
      return continue
   end

   function ctrl.showdown(ctrl)
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
      local result
      for i=2,#in_players do
         result = compare_hands(in_hands[best], in_hands[in_players[i]])
         if result == 0 then
            table.insert(winners, in_players[i])
         elseif result == 1 then
            best = in_players[i]
            winners = {in_players[i]}
         end
      end

      best.money = best.money + pot
      pot = 0

      print("player won with")
      for _, card in ipairs(in_hands[best]) do
         print(card.name)
      end
      pres:showdown(winners)
      enable_event_listener(Events.TIMER, 3)
      return true
   end

   function ctrl.on_event(ctrl)
      print(#hand_pipeline, "entries left in hand_pipeline")
      if #hand_pipeline > 0 then
         local next_action = hand_pipeline[1]
         local result = next_action(ctrl)
         if result then table.remove(hand_pipeline, 1) end
      end

      if #hand_pipeline > 0 then
         return false
      else
         return true
      end
   end

   function ctrl.cleanup(ctrl)
      pres:clear_ui()
      return true
   end
end)