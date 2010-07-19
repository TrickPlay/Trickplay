local MenuItems = {
   CONTINUE=1,
   NEW_GAME=2,
   HUMANS=3,
   EXIT=4
}
local MenuSize = 0
for k, v in pairs(MenuItems) do
   MenuSize = MenuSize + 1
end

MainMenuController = {}
function MainMenuController:new(view)
   local view = view or
      error("View is nil", 2)
   local model = view.model or
      error("Model is nil in MainMenuController constructor argument view", 2)
   local selected = 2
   local object = {
      view=view,
      model=model,
      selected=2,
      disabled_items={
	 [MenuItems.CONTINUE] = true
      }
   }
   setmetatable(object, self)
   self.__index = self
   model:attach(object, Components.MAIN_MENU)
   return object
end

function MainMenuController:update()
   if not self.model:is_game_active() then
      self.disabled_items[MenuItems.CONTINUE] = true
   else
      self.disabled_items[MenuItems.CONTINUE] = nil
   end
   self.view:update()
end

local MenuItemCallbacks = {
   [MenuItems.CONTINUE]=
      function(self)
	 self.model:set_active_component(Components.GAME)
	 self.view:animate_to_game()
      end,
   [MenuItems.NEW_GAME]=
      function(self)
	 self.model:set_active_component(Components.REROLL_MENU)
	 self.view:animate_to_reroll_menu(
	    function()
	       self.model:lay_out_new_game()
	    end
	 )
      end,
   [MenuItems.HUMANS]=
      function(self)
	 -- nothing happens
      end,
   [MenuItems.EXIT]=
      function(self)
	 self.model:try_save()
	 exit()
      end
}

local MainMenuKeyTable = {
   [keys.Up] = function(self) self:move_selector(-1) end,
   [keys.Down] = function(self) self:move_selector(1) end,
   [keys.Left] = function(self) self:check_selection_and_adjust_humans(-1) end,
   [keys.Right] = function(self) self:check_selection_and_adjust_humans(1) end,
   [keys.Return] =
      function(self)
	 local success, error_msg = pcall(MenuItemCallbacks[self.selected], self)
	 if not success then print(error_msg) end
      end
}

function MainMenuController:on_key_down(k)
   if not pcall(MainMenuKeyTable[k], self) then
      print("Couldn't process key: " .. k)
   end
end

function MainMenuController:move_selector(delta)
   local new_selected = self.selected + delta
   if self.disabled_items[1] then
      if 2 <= new_selected and new_selected <= MenuSize then
	 self.selected = new_selected
      end
   else
      if 1 <= new_selected and new_selected <= MenuSize then
	 self.selected = new_selected
      end
   end
   self.model:notify()
end

function MainMenuController:check_selection_and_adjust_humans(delta)
   if self.selected ~= MenuItems.HUMANS then
      return
   end

   local new_count = self.model.num_human_players + delta
   if 1 <= new_count and new_count <= 4 then
      self.model:set_num_human_players(new_count)
   end
end