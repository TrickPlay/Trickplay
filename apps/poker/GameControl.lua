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

   local in_hand = false

   local game_pipeline = {}
   local orig_game_pipeline = {
      function(ctrl)
         hand_ctrl:initialize()
         enable_event_listener(Events.TIMER, 1)
         local continue = true
         return continue
      end,
      function(ctrl)
         local continue = hand_ctrl:on_event()
         enable_event_listener(Events.TIMER, 1)
         return continue
      end,
      function(ctrl)
         screen:add(
            Text{
               text="Pipeline stage 3 triggered",
               font="Sans 40px",
               color="FFFFFF",
               y=100
            }
         )
         enable_event_listener(Events.TIMER, 1)
         return true
      end,
      function(ctrl)
         screen:add(
            Text{
               text="Pipeline stage 4 triggered",
               font="Sans 40px",
               color="FFFFFF",
               y=200
            }
         )
         enable_event_listener(Events.TIMER, 1)
         return true
      end,
   }

   -- getters/setters
   function ctrl.get_players(ctrl) return state:get_players() end
   function ctrl.get_sb_qty(ctrl) return state:get_sb_qty() end
   function ctrl.get_bb_qty(ctrl) return state:get_bb_qty() end
   function ctrl.get_dealer(ctrl) return state:get_dealer() end
   function ctrl.get_sb_p(ctrl) return state:get_sb_p() end
   function ctrl.get_bb_p(ctrl) return state:get_bb_p() end
   function ctrl.get_deck(ctrl) return state:get_deck() end


   -- public functions
   function ctrl.initialize_game(ctrl, args)
      state:initialize(args)
      pres:display_ui()

      -- reset pipeline
      game_pipeline = {}
      for _, stage in ipairs(orig_game_pipeline) do
         table.insert(game_pipeline,stage)
      end

      disable_event_listeners()
      enable_event_listener(Events.TIMER, 1)
   end

   function ctrl.start_hand(ctrl)
      hand_ctrl:initialize()
   end
   
   function ctrl.on_event(ctrl, event, extra)
      disable_event_listeners()

      if #game_pipeline > 0 then
         local action = game_pipeline[1]
         local result = action(ctrl)
         if result then table.remove(game_pipeline, 1) end
      else
         enable_event_listener(Events.KEYBOARD)
      end
   end
end)