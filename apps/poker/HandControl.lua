dofile("HandState.lua")
dofile("HandPresentation.lua")

HandControl = Class(nil,function(ctrl, game_ctrl, ...)
   local state = HandState(ctrl)
   local pres = HandPresentation(ctrl)
   local game_ctrl = game_ctrl or error("no game_ctrl",2)
--   local bet_ctrl = BettingControl(ctrl)

   local round = Rounds.HOLE
   local hand_pipeline = {}
   local orig_hand_pipeline = {
      function(ctrl) return ctrl:deal(Rounds.HOLE) end,
      function(ctrl, event) return ctrl:bet(Rounds.HOLE, event) end,
      function(ctrl) return ctrl:deal(Rounds.FLOP) end,
      function(ctrl, event) return ctrl:bet(Rounds.FLOP, event) end,
      function(ctrl) return ctrl:deal(Rounds.TURN) end,
      function(ctrl, event) return ctrl:bet(Rounds.TURN, event) end,
      function(ctrl) return ctrl:deal(Rounds.RIVER) end,
      function(ctrl, event) return ctrl:bet(Rounds.RIVER, event) end,
      function(ctrl) return ctrl:showdown() end
   }

   -- true if everyone's all in
   local bets_done = false
   function ctrl:set_bets_done(boo)
      bets_done = boo
      pres:all_cards_up()
   end
   function ctrl:get_community_cards() return state:get_community_cards() end
   function ctrl:get_hole_cards() return state:get_hole_cards() end
   function ctrl:get_player_bets() return state:get_player_bets() end
   function ctrl:get_pot() return state:get_pot() end
   function ctrl:get_pots() return state:get_pots() end
   function ctrl:are_side_pots() return #state:get_pots() > 1 end
   function ctrl:get_action() return state:get_action() end
   function ctrl:get_players() return state:get_players() end
   function ctrl:get_sb_qty() return state:get_sb_qty() end
   function ctrl:get_bb_qty() return state:get_bb_qty() end
   function ctrl:get_sb_p() return state:get_sb_p() end
   function ctrl:get_bb_p() return state:get_bb_p() end
   function ctrl:get_deck() return state:get_deck() end
   function ctrl:get_round() return round end
   function ctrl:get_out_table() return state:get_out_table() end
   function ctrl:get_in_hands() return state:get_in_hands() end
   function ctrl:get_final_hands() return state:get_final_hands() end

   -- private functions
   local function initialize_pipeline()
      hand_pipeline = {}
      for _,stage in ipairs(orig_hand_pipeline) do
         table.insert(hand_pipeline, stage)
      end
   end

   function ctrl:reset()
      bets_done = false
      ctrl.waiting_for_bet = false
   end

   -- public functions
   function ctrl:clear_pipeline()
      hand_pipeline = {}
   end

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

      print("Hand initializing")

      initialize_pipeline()
      pres:display_hand()

      enable_event_listener(TimerEvent{interval=1000})
   end


   function ctrl.deal(ctrl, rd)
      round = rd
      pres:deal(round)
      enable_event_listener(TimerEvent{interval=1000})
      return true
   end


   -- Handle betting stage of a hand.
   -- preconditions: active player 
   --
   -- postconditions: action var indexes current active player. also,
   -- proper event listener set up. if current active player is a
   -- human, then event listener waits for on_event call from 

   print("defined and set waiting_for_bet to false")
   ctrl.waiting_for_bet = false
   function ctrl.bet(ctrl, rd, event)
      bets_done = state:get_bets_done()
      if bets_done then
         enable_event_listener(TimerEvent{interval=300})
         return true
      end
      print("HandControl:bet(" .. tostring(rd) .. ", event)")
      round = rd
      local continue = false
      if ctrl.waiting_for_bet and event:is_a(BetEvent) then
         ctrl.waiting_for_bet = false
         local active_player = state:get_active_player()
         continue = state:execute_bet(event.fold, event.bet)
         pres:finish_turn(active_player)
         enable_event_listener(TimerEvent{interval=1000})
      elseif not ctrl.waiting_for_bet then
         ctrl.waiting_for_bet = true
         local active_player = state:get_active_player()
         pres:start_turn(active_player)
         if active_player.isHuman then
            model.currentPlayer = active_player
            model.orig_bet = state:get_player_bets()[active_player]
            model.orig_money = model.orig_bet + active_player.money
            model.call_bet = state:get_call_bet()
            model.min_raise = state:get_min_raise()
            model.max_bet = state:get_max_bet()
            model.in_players = state:get_in_players()
            model.bb_p = state:get_bb_p()
            model.bb_qty = state:get_bb_qty()
            model:set_active_component(Components.PLAYER_BETTING)
            model:get_active_controller():set_callback(
               function(fold, bet) 
                  enable_event_listener(
                     TimerEvent{
                        interval=100,
                        cb=function()
                           game_ctrl:on_event(BetEvent{fold=fold, bet=bet})
                        end})
               end)
            enable_event_listener(KbdEvent())
            model:notify()
         else
            local fold, bet = active_player:get_move(state)
            local orig_bet = state:get_player_bets()[state:get_active_player()]
            print("computer move, activeplayer money was $" .. active_player.money)
            if not fold then
               assert(bet, "bet = "..bet)
               assert(orig_bet, "orig_bet = "..bet)
               assert(
                  orig_bet <= bet,
                  "bet ($".. bet ..") should be at least as much as previous bet ($"..orig_bet..")."
               )
               assert(
                  bet <= active_player.money+orig_bet,
                  "bet ($".. bet ..") should max out at player's bank plus original bet ($"..active_player.money+orig_bet..")."
               )
               active_player.money = active_player.money + orig_bet - bet
               assert(active_player.money >= 0, "WTF? money went negative.")
            end
            print("computer move, activeplayer money now $" .. active_player.money)
            enable_event_listener(
               TimerEvent{
                  interval=1000,
                  cb=function()
                        game_ctrl:on_event(BetEvent{fold=fold, bet=bet})
                     end})
         end
      end
      if continue then ctrl.waiting_for_bet = false end
      return continue
   end

   function ctrl:fold_player(active_player)
      pres:fold_player(active_player)
   end

   function ctrl:check_player(active_player)
      pres:check_player(active_player)
   end
   function ctrl:call_player(active_player)
      pres:call_player(active_player)
   end

   function ctrl:raise_player(active_player)
      pres:raise_player(active_player)
   end

   function ctrl:all_in_player(active_player)
      pres:all_in_player(active_player)
   end

   function ctrl.showdown(ctrl)
      local winners, poker_hand = state:showdown()
      pres:showdown(winners, poker_hand)
      state:remove_players()
      ---[[
      if game:game_won() then
         enable_event_listener(
            TimerEvent{interval=800}
         )
      else
         enable_event_listener(KbdEvent())
      end
      --]]enable_event_listener(KbdEvent())
      
      return true
   end

   function ctrl.on_event(ctrl, event)
      print(#hand_pipeline, "entries left in hand_pipeline")
      if #hand_pipeline > 0 then
         local next_action = hand_pipeline[1]
         local continue = next_action(ctrl, event)
         if continue then 
            print("removing action from hand_pipeline")
            table.remove(hand_pipeline, 1)
         end
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

   function ctrl:remove_player(removed_player)
      pres:remove_player(removed_player)
   end

   function ctrl:win_from_bets(only_player)
      pres:win_from_bets(only_player)
   end

   function ctrl:betting_round_over()
      pres:betting_round_over()
   end
end)
