dofile ("Assets.lua")

-- Asset loading ---------------------------------------------------------------
AssetLoader:construct()
AssetLoader:preloadImage("Table","assets/table.png")
AssetLoader:preloadImage("TableText","assets/UI/new/table_text.png")

AssetLoader:preloadImage("BubbleNone","assets/UI/BubbleWhite.png")

AssetLoader:preloadImage("ChooseDog","assets/ChooseYourDog.png")
AssetLoader:preloadImage("ChooseAI","assets/ChooseYourOpponents.png")


AssetLoader:preloadImage("Win","assets/outcome/winner.png")
AssetLoader:preloadImage("Lose","assets/outcome/loser.png")



-- Tutorial Slides
for i=1, 4 do
   AssetLoader:preloadImage("Tutorial"..i,"assets/Tutorial/"..i..".png")
end

AssetLoader:preloadImage("pot_glow_img", "assets/UI/new/pot_glow.png")

-- Buttons
local ui_colors = {"Red", "Green", "Gray"}
local ui_buttons = {
   "Bubble", "ButtonArrowDown", "ButtonArrowUp",
   "ButtonBet", "ButtonCall", "ButtonFold", "ButtonStart", "ButtonExit"
}
for _,color in pairs(ui_colors) do
   for _,button in pairs(ui_buttons) do
      AssetLoader:preloadImage(button..color,"assets/UI/"..button..color..".png")
   end
end

-- Load new UI elements
AssetLoader:preloadImage("BetArrowUp","assets/UI/new/betarrow_up.png")
AssetLoader:preloadImage("BetArrowDown","assets/UI/new/betarrow_down.png")

local button_types = { "focused", "default" }
local button_names = { "fold", "call", "bet", "check", "exit", "help", "start" }

for i, type in pairs(button_types) do
   for k, name in pairs(button_names) do
      if i==1 or k>3 then
         AssetLoader:preloadImage(name.."_"..type,"assets/UI/new/"..name.."_"..type..".png")
      end
   end
end

DOGS = {}

-- Dog images
for i=1,6 do
   AssetLoader:preloadImage("dog"..i,"assets/dogs/dogs/"..i..".png")
end

-- Dog animations
DOG_ANIMATIONS = {
   [1] = {dog = 1, name = "animation_bling", frames = 11, position = {90, 538}, speed = 60 },
   [2] = {dog = 2, name = "animation_smoke", frames = 7, position = {170,0}, speed = 100 },
   [3] = {dog = 3, name = "animation_slideglass", frames = 5, position = {341, 9}, speed = 100 },
   [4] = {dog = 4, name = "animation_cards", frames = 5, position = {1144, 22}, speed = 140 },
   [5] = {dog = 5, name = "animation_music", frames = 7, position = {1607, 186}, speed = 160 },
   [6] = {dog = 6, name = "animation_jacket", frames = 10, position = {1404, 572}, speed = 100 },
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
   [1] = {90, 538},
   [2] = {0, 144},
   [3] = {488, 0},
   [4] = {1156, 14},
   [5] = {1626, 136},
   [6] = {1468, 568},
}

--[[
DOG_GLOW = {
   [1] = {90, 537},
   [2] = {0, 143},
   [3] = {487, 0},
   [4] = {1154, 13},
   [5] = {1624, 135},
   [6] = {1466, 567},
}
--]]

for i=1, 6 do
   AssetLoader:preloadImage("dog"..i.."glow","assets/dogs/glow/"..i..".png")
end

DOG_LAYER = Group{}
DOG_GLOW_LAYER = Group{}
DOG_ANIMATION_LAYER = Group{}

--------------------------------------------------------------------------------

AssetLoader.on_preload_ready =
function()
   --a = AssetLoader:getImage("fold_focused",{})
   --screen:add( a )
   screen:add( AssetLoader:getImage("Table",{name="TableBackground"}) )

   screen:add(DOG_LAYER, DOG_GLOW_LAYER, DOG_ANIMATION_LAYER)
   for i=1, 6 do
      DOGS[i] = AssetLoader:getImage("dog"..i,{position = DOG_GLOW[i], opacity = 0, name = "Dog "..i})
      DOG_LAYER:add(DOGS[i])
      DOG_GLOW[i] = AssetLoader:getImage("dog"..i.."glow",{position = DOG_GLOW[i], opacity=255, name = "Dog "..i.. "glow"} )
      DOG_GLOW_LAYER:add(DOG_GLOW[i])
   end
   pot_glow_img=AssetLoader:getImage("pot_glow_img",{opacity=0,position={839,627}})
   screen:add(pot_glow_img)
   
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
      if k == keys.s then
         t:complete()
      elseif not t.enabled then
         assert(model:get_active_controller())
         print("current comp: "..model:get_active_component())
         model:get_active_controller():on_key_down(k)
      end
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
      -- if screen.on_key_down then
      --    old_on_key_down, screen.on_key_down = screen.on_key_down, nil
      -- end
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
--   model:start_app(Components.PLAYER_BETTING)

   AssetLoader.on_preload_ready = nil
end
