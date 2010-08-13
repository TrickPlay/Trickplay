dofile ("Assets.lua")

AssetLoader:construct()
AssetLoader:preloadImage("Table","assets/table.png")

AssetLoader.on_preload_ready =
function()
   screen:add( AssetLoader:getImage("Table",{name="TableBackground"}) )
   dofile("Class.lua") -- Must be declared before any class definitions.
   dofile("Globals.lua")
   --dofile("Utils.lua")
   dofile("MVC.lua")
   dofile("Views.lua")
   dofile("Chip.lua")
   dofile("Player.lua")
   dofile("Popup.lua")
   dofile("TimerWrapper.lua")
   dofile("GameControl.lua")


   Components = {
      CHARACTER_SELECTION = 1,
      PLAYER_BETTING = 2,
      GAME = 3
   }

   -- Model initialization
   local model = Model()

   -- View/Controller initialization
   BettingView(model):initialize()
   CharacterSelectionView(model):initialize()

   function screen:on_key_down(k)
      assert(model:get_active_controller())
      print("current comp: "..model:get_active_component())
      model:get_active_controller():on_key_down(k)
   end
   Events = {
      KEYBOARD = 1,
      TIMER = 2
   }
   -- private (helper) functions
   function disable_event_listeners()
      old_on_key_down, screen.on_key_down = screen.on_key_down, function() end
      t:disable()
   end

   function enable_event_listener(event, interval)
      if event == Events.KEYBOARD then
         screen.on_key_down, old_on_key_down = old_on_key_down, function() end
      elseif event == Events.TIMER then
         t:enable{
            on_timer=function()
                        game:on_event(Events.TIMER)
                     end,
            interval=interval
         }
      end
   end
   game = GameControl(model)
   local players = {}
   table.insert(players,
                Player{
                   isHuman=true,
                   table_position=1
                })
   for i=2,6 do
      table.insert(
         players,
         Player{
            isHuman=true,
            table_position=i
         })
   end
   game:initialize_game{
      sb=1,
      bb=2,
      endowment=800,
      players=players
   }
   old_on_key_down = nil
   model:start_app(Components.GAME)
   AssetLoader.on_preload_ready = nil
end
