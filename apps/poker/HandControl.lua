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
      function(ctrl, event) return ctrl:bet(Rounds.HOLE, event) end,
      function(ctrl) return ctrl:deal(Rounds.FLOP) end,
      function(ctrl, event) return ctrl:bet(Rounds.FLOP, event) end,
      function(ctrl) return ctrl:deal(Rounds.TURN) end,
      function(ctrl, event) return ctrl:bet(Rounds.TURN, event) end,
      function(ctrl) return ctrl:deal(Rounds.RIVER) end,
      function(ctrl, event) return ctrl:bet(Rounds.RIVER, event) end,
      function(ctrl) return ctrl:showdown() end
   }

   function ctrl:get_community_cards() return state:get_community_cards() end
   function ctrl:get_hole_cards() return state:get_hole_cards() end
   function ctrl:get_player_bets() return state:get_player_bets() end
   function ctrl:get_pot() return state:get_pot() end
   function ctrl:get_action() return state:get_action() end
   function ctrl:get_players() return state:get_players() end
   function ctrl:get_sb_qty() return state:get_sb_qty() end
   function ctrl:get_bb_qty() return state:get_bb_qty() end
   function ctrl:get_sb_p() return state:get_sb_p() end
   function ctrl:get_bb_p() return state:get_bb_p() end
   function ctrl:get_deck() return state:get_deck() end

   -- private functions
   function ctrl:give_winner_pot_and_bone_out()
      state:give_winner_pot()

      
      hand_pipeline = {}
      enable_event_listener(KbdEvent())
   end

   local function initialize_pipeline()
      hand_pipeline = {}
      for _,stage in ipairs(orig_hand_pipeline) do
         table.insert(hand_pipeline, stage)
      end
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

      initialize_pipeline()
      pres:display_hand()

      enable_event_listener(TimerEvent{interval=.5})
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
      enable_event_listener(TimerEvent{interval=.5})
      return true
   end


   -- Handle betting stage of a hand.
   -- preconditions: active player 
   --
   -- postconditions: action var indexes current active player. also,
   -- proper event listener set up. if current active player is a
   -- human, then event listener waits for on_event call from 

   print("defined and set waiting_for_bet to false")
   local waiting_for_bet = false
   function ctrl.bet(ctrl, round, event)
      print("entering ctrl:bet, and waiting_for_bet is", waiting_for_bet)
      local continue = false
      if waiting_for_bet and event:is_a(BetEvent) then
         print("setting waiting_for_bet to false")
         waiting_for_bet = false
         continue = state:execute_bet(event.bet)
         print("setting up timerevent in ctrl.bet, where waiting_for_bet is", waiting_for_bet)
         game_ctrl:on_event(Event{})
      elseif not waiting_for_bet then
         print("generating a bet, and setting waiting_for_bet to true")
         waiting_for_bet = true
         local active_player = state:get_active_player()
         if active_player.isHuman then
            model.currentPlayer = active_player
            model.in_players = state:get_in_players()
            model:set_active_component(Components.PLAYER_BETTING)
            model:get_active_controller():set_callback(function(bet) game_ctrl:on_event(BetEvent{bet=bet}) end)
            enable_event_listener(KbdEvent())
         else
            local bet = active_player:get_move(state)
            enable_event_listener(
               TimerEvent{
                  interval=1,
                  cb=function()
                        game_ctrl:on_event(BetEvent{bet=bet})
                  end})
         end
      end
      if continue then waiting_for_bet = false end
      return continue
   end

   function ctrl:fold_player(active_player)
      pres:fold_player(active_player)
   end

   function ctrl:bet_player(active_player)
      pres:bet_player(active_player)
   end

   function ctrl.showdown(ctrl)
      local winners, poker_hand = state:showdown()
      pres:showdown(winners, poker_hand)
      enable_event_listener(KbdEvent())
      return true
   end

   function ctrl.on_event(ctrl, event)
      print(#hand_pipeline, "entries left in hand_pipeline")
      if #hand_pipeline > 0 then
         local next_action = hand_pipeline[1]
         local result = next_action(ctrl, event)
         if result then 
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

   function ctrl:set_betting_listener(callback, player)
      game_ctrl:set_bet_listener(callback, player)
   end
end)