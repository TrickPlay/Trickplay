dofile("GameState.lua")
dofile("GamePresentation.lua")
dofile("HandControl.lua")

GameControl = Class(nil,
function(ctrl, model, ...)
   model:attach(ctrl, Components.GAME)
   function ctrl:update()end

   local state = GameState(ctrl)
   local pres = GamePresentation(ctrl)
   local hand_ctrl = HandControl(ctrl)
   local model = model
   local in_hand = false

   local game_pipeline = {}
   local orig_game_pipeline = {
      function(ctrl)
         hand_ctrl:initialize()
         enable_event_listener(TimerEvent{interval=1})
         local continue = true
         return continue
      end,
      -- stage where we play through a hand
      function(ctrl, event)
         local continue = hand_ctrl:on_event(event)
         return continue
      end,
      function(ctrl)
         state:move_blinds()
         local continue = hand_ctrl:cleanup()
         enable_event_listener(TimerEvent{interval=1})
         pres:finish_hand()
         return continue
      end
   }

   local help_game_pipeline = {
      function(ctrl)
         hand_ctrl:initialize()
         enable_event_listener(TimerEvent{interval=1})
         local continue = true
         return continue
      end,
      -- stage where we play through a hand
      function(ctrl, event)
         local continue = hand_ctrl:on_event(event)
         return continue
      end,
      function(ctrl)
         state:move_blinds()
         local continue = hand_ctrl:cleanup()
         enable_event_listener(TimerEvent{interval=1})
         pres:finish_hand()
         return continue
      end
   }
   -- getters/setters
   function ctrl.get_players(ctrl) return state:get_players() end
   function ctrl.get_sb_qty(ctrl) return state:get_sb_qty() end
   function ctrl.get_bb_qty(ctrl) return state:get_bb_qty() end
   function ctrl.get_dealer(ctrl) return state:get_dealer() end
   function ctrl.get_sb_p(ctrl) return state:get_sb_p() end
   function ctrl.get_bb_p(ctrl) return state:get_bb_p() end
   function ctrl.get_deck(ctrl) return state:get_deck() end


   local function reset_pipeline()
      game_pipeline = {}
      for _, stage in ipairs(orig_game_pipeline) do
         table.insert(game_pipeline,stage)
      end
   end

   -- public functions
   function ctrl.initialize_game(ctrl, args)

      state:initialize(args)
      pres:display_ui()

      reset_pipeline()
      disable_event_listeners()
      enable_event_listener(TimerEvent{interval=1})
   end

   function ctrl.start_hand(ctrl)
      hand_ctrl:initialize()
   end
   
   function ctrl.on_key_down(ctrl, key)
      ctrl:on_event(KbdEvent{key=key})
   end

   function ctrl.on_event(ctrl, event)
      assert(event:is_a(Event))
      if event:is_a(BetEvent) then
         print("GameControl:on_event(BetEvent)")
      elseif event:is_a(TimerEvent) then
         print("GameControl:on_event(TimerEvent)")
      elseif event:is_a(KbdEvent) then
         print("GameControl:on_event(KbdEvent)")
      else
         print("GameControl:on_event(Event)")
      end
      print(#game_pipeline, "entries left in game pipeline")
      disable_event_listeners()

      if #ctrl:get_players() == 1 then
         pres:return_to_main_menu()
         enable_event_listener(KbdEvent())
         model:set_active_component(Components.CHARACTER_SELECTION)
         model:notify()
         return
      end

      if #game_pipeline == 0 then
         reset_pipeline()
      end

      local action = game_pipeline[1]
      local result = action(ctrl, event)
      if result then table.remove(game_pipeline, 1) end

      -- if #game_pipeline > 0 then
      --    local action = game_pipeline[1]
      --    local result = action(ctrl)
      --    if result then table.remove(game_pipeline, 1) end
      -- else
      --    enable_event_listener(Events.KEYBOARD)
      -- end
   end

   function ctrl:set_bet_listener(callback, player)
      error("GameControl:set_bet_listener called")
      if player.isHuman then
         model.currentPlayer = player
         model:set_active_component(Components.PLAYER_BETTING)
         model:get_active_controller():set_callback(callback)
         enable_event_listener(KbdEvent())
      else
         
      end
   end
end)