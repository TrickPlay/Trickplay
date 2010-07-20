Model = {}
function Model:new(args)
   local num_human_players = args and args.init_players or 2
   
   local object = {
      num_human_players = num_human_players,
      previous_component = nil,
      active_component = nil,
      is_screen_shown = false,
      registry = {},
      controllers = {},
      reroll_menu={
	 selected=1
      },
      game = nil,
      game_done = nil
   }
   setmetatable(object, self)
   self.__index = self
   return object
end

function Model:attach(observer, controller_id)
   self.registry[observer] = true
   if controller_id then
      self.controllers[controller_id] = observer
      print("set controller with controller_id " .. controller_id)
   end
end

function Model:detach(observer)
   self.registry[observer] = nil
end

function Model:notify()
   for observer, v in pairs(self.registry) do
      observer:update()
   end
end

function Model:start_app()
   self:set_active_component(Components.ADDRESS_INPUT)
   --[[
   
   local is_save_game = settings.num_human_players and settings.dice_per_country and settings.player_to_move and settings.country_owners
   if is_save_game then
      
      -- print("num_human_players:", settings.num_human_players)
      -- print("player_to_move:", settings.player_to_move)

      -- print("DICEPERCOUNTRY")
      -- for k,v in pairs(settings.dice_per_country) do
      -- 	 print(k,v)
      -- end

      -- print("OWNERS")
      -- for k,v in pairs(settings.country_owners) do
      -- 	 print(k,v)
      -- end
      

      self.game = GameControl:new(
	 settings.num_human_players, --num_human_players
	 self, -- model
	 { -- saved_state
	    player_to_move=settings.player_to_move,
	    dice_per_country=settings.dice_per_country,
	    country_owners=settings.country_owners
	 })
      self.controllers[Components.GAME] = self.game
      self.game:resume()
      self.game:show()
      self.controllers[Components.MAIN_MENU].selected = 1
   end
   --]]
   self:notify()
end

function Model:set_active_component(comp)
   self.previous_component = self.active_component
   self.active_component = comp
end

function Model:get_active_controller()
   return self.controllers[self.active_component]
end

function Model:set_game_inactive()
   self.game = nil
end

function Model:is_game_active()
   return type(self.game) ~= "nil"
end

function Model:set_num_human_players(num)
   self.num_human_players = num
   self:notify()
end

function Model:lay_out_new_game()
   if type(self.game) ~= "nil" then
      self.game:destroy()
   end
   self.game = GameControl:new(self.num_human_players, self)
   self.controllers[Components.GAME] = self.game
   self.game:initialize()
   self.game:show()
end

function Model:try_save()
   if type(self.game) ~= "nil" then
      self.game:save()
   else
      settings.num_human_players = nil
      settings.dice_per_country = nil
      settings.player_to_move = nil
      settings.country_owners =nil
   end
end
