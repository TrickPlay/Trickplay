dofile ("Assets.lua")

-- Asset loading ---------------------------------------------------------------
AssetLoader:construct()
AssetLoader:preloadImage("Table","assets/table.png")
AssetLoader:preloadImage("BubbleNone","assets/UI/BubbleNone.png")


local ui_colors = {"Red", "Green", "Gray"}
local ui_buttons = {"BubbleHeader", "ButtonArrayDown", "ButtonArrowUp", "ButtonBet", "ButtonCall", "ButtonFold", "ButtonStart", "ButtonExit"}

for _,color in pairs(ui_colors) do
   for _,button in pairs(ui_buttons) do
      AssetLoader:preloadImage(button..color,"assets/UI/"..button..color..".png")
   end
end

local player_text = {"BubbleLeft", "BubbleRight"}
for i=1, 2 do
   for _, text in ipairs(player_text) do
      AssetLoader:preloadImage(text..i,"assets/UI/"..text..i..".png")
   end
end
--------------------------------------------------------------------------------

AssetLoader.on_preload_ready =
function()
   screen:add( AssetLoader:getImage("Table",{name="TableBackground"}) )
   dofile("Class.lua") -- Must be declared before any class definitions.
   dofile("Globals.lua")
   --dofile("Utils.lua")
   dofile("MVC.lua")
   dofile("FocusableImage.lua")
   dofile("Views.lua")
   dofile("Chip.lua")
   dofile("Player.lua")
   dofile("Popup.lua")
   dofile("TimerWrapper.lua")
   dofile("GameControl.lua")
   dofile("PokerRules.lua")
   dofile("PreFlopLUT.lua")
   dofile("Events.lua")

   Components = {
      COMPONENTS_FIRST = 1,
      CHARACTER_SELECTION = 1,
      PLAYER_BETTING = 2,
      GAME = 3,
      COMPONENTS_LAST = 3
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
      TIMER = 2,
      BET_READY = 3,
      BET_READY_AND_TIMER = 4,
   }
   local old_on_key_down
   local event_listener_en = true
   -- private (helper) functions
   function disable_event_listeners()
      if screen.on_key_down then
         old_on_key_down, screen.on_key_down = screen.on_key_down, nil
      end
      t:disable()
      event_listener_en = false
   end

   function enable_event_listener(event)
      assert(event:is_a(Event))
      if event:is_a(KbdEvent) then
         print("enable_event_listener(KbdEvent())")
         if old_on_key_down then
            screen.on_key_down, old_on_key_down = old_on_key_down, nil
         end
      elseif event:is_a(TimerEvent) then
         print("enable_event_listener(TimerEvent{interval=" .. event.interval .. "})")
         local cb = event.cb or
            function()
               game:on_event(event)
            end
         t:enable{
            on_timer=cb,
            interval=event.interval
         }
      end
      event_listener_en = true
   end

   function event_listener_enabled()
      return event_listener_en
   end

   game = GameControl(model)
   model:start_app(Components.CHARACTER_SELECTION)
   -- local p = Player{position={100,100}, chipPosition={200,200}}
   -- p:createBetChips()
   -- model.players = {p}
   -- model.currentPlayer = 1

--   model:start_app(Components.PLAYER_BETTING)

   AssetLoader.on_preload_ready = nil
end
