dofile ("Assets.lua")

-- Asset loading ---------------------------------------------------------------
AssetLoader:construct()
AssetLoader:preloadImage("Table","assets/table.png")
AssetLoader:preloadImage("BubbleNone","assets/UI/BubbleNone.png")
AssetLoader:preloadImage("TutorialGameplay","assets/TutorialGameplay.png")

-- Buttons
local ui_colors = {"Red", "Green", "Gray"}
local ui_buttons = {
   "BubbleHeader", "ButtonArrowDown", "ButtonArrowUp",
   "ButtonBet", "ButtonCall", "ButtonFold", "ButtonStart", "ButtonExit"
}
for _,color in pairs(ui_colors) do
   for _,button in pairs(ui_buttons) do
      AssetLoader:preloadImage(button..color,"assets/UI/"..button..color..".png")
   end
end

-- Player text bubbles
local player_text = {"BubbleLeft", "BubbleRight"}
for i=1, 2 do
   for _, text in ipairs(player_text) do
      AssetLoader:preloadImage(text..i,"assets/UI/"..text..i..".png")
   end
end

-- Dog animations
DOG_ANIMATIONS = {
   [1] = {dog = 1},
   [2] = {dog = 2, name = "animation_smoke", frames = 7, position = {170,0} },
   [3] = {dog = 3, name = "animation_slideglass", frames = 5, position = {340, 5} },
   [4] = {dog = 4, name = "animation_cards", frames = 5, position = {1144, 22} },
   [5] = {dog = 5, name = "animation_music", frames = 7, position = {1750, 10} },
   [6] = {dog = 6},
}

for i, t in ipairs(DOG_ANIMATIONS) do
   if t.frames then  
      for j=1, t.frames do
         AssetLoader:preloadImage("dog"..i.."frame"..j,"assets/dogs/"..t.name.."/"..j..".png")
         print("assets/dogs/animation_smoke/"..j..".png")
      end
   end
end

-- Dog glows
DOG_GLOW = {
   [1] = {90, 537},
   [2] = {0, 143},
   [3] = {487, 0},
   [4] = {1154, 13},
   [5] = {1624, 135},
   [6] = {1466, 567},
}
for i=1, 6 do
   AssetLoader:preloadImage("dog"..i.."glow","assets/dogs/glow/"..i..".png")
end

DOG_GLOW_LAYER = Group{}
DOG_ANIMATION_LAYER = Group{}

--------------------------------------------------------------------------------

AssetLoader.on_preload_ready =
function()
   screen:add( AssetLoader:getImage("Table",{name="TableBackground"}) )
   screen:add(DOG_GLOW_LAYER, DOG_ANIMATION_LAYER)
   for i=1, 6 do
      DOG_GLOW[i] = AssetLoader:getImage("dog"..i.."glow",{position = DOG_GLOW[i], opacity=0} )
      DOG_GLOW_LAYER:add(DOG_GLOW[i])
   end
   
   --DOG = AssetLoader:getImage("dog1glow",{})
   --screen:add( DOG )
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
   dofile("Animate.lua")

   Components = {
      COMPONENTS_FIRST = 1,
      CHARACTER_SELECTION = 1,
      PLAYER_BETTING = 2,
      GAME = 3,
      TUTORIAL = 4,
      COMPONENTS_LAST = 4
   }

   -- Model initialization
   local model = Model()

   -- View/Controller initialization
   BettingView(model):initialize()
   CharacterSelectionView(model):initialize()
   TutorialView(model):initialize()

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
--         print("enable_event_listener(KbdEvent())")
         if old_on_key_down then
            screen.on_key_down, old_on_key_down = old_on_key_down, nil
         end
      elseif event:is_a(TimerEvent) then
--         print("enable_event_listener(TimerEvent{interval=" .. event.interval .. "})")
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
