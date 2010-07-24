Directions = {
   RIGHT = {1,0},
   LEFT = {-1,0},
   DOWN = {0,1},
   UP = {0,-1}
}

 CustomizeController = Class(Controller,
   function(self, view, ...)
      self._base.init(self, view, Component.CUSTOMIZE)

   local selected = 1
   local MenuSize = 5

--[[
      local MenuItems = {}
      for i,opt in ipairs(view.menu_items) do
         MenuItems[opt.text] = i
      end
      local MenuSize = #view.menu_items


      -- the default selected index
      local selected = 1

      local MenuItemCallbacks = {}
      for opt,i in pairs(MenuItems) do
         MenuItemCallbacks[i] = 
            function(self)
               print(opt.." selected")
            end
      end
--]]
--[[
      local MenuItemCallbacks)
      for i = 1,#food_menu.Selections do
         local item = "MenuItems."..i
         MenuItemCallbacks[item] = function(self)
            print(food_menu[i].Name.." selected")
--            food_menu[i].Select()
         end
      end]]
      local MenuKeyTable = {
         [keys.Up]    = function(self) self:move_selector(Directions.UP) end,
         [keys.Down]  = function(self) self:move_selector(Directions.DOWN) end,
         [keys.Left]  = function(self) self:move_selector(Directions.LEFT) end,
         [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end--,
         --[[
         [keys.Return] =
            function(self)
               -- compromise so that there's not a full-on lua panic,
               -- but the error message still displays on screen
               local success, error_msg = pcall(MenuItemCallbacks[selected], self)
               if not success then print(error_msg) end
            end
         --]]
      }

      function self:on_key_down(k)
         --print("Customize_controller on_key_down called with key", k)
         if MenuKeyTable[k] then
            MenuKeyTable[k](self)
         end
      end

      function self:get_selected_index()
         --print("\tCustomize index:",selected .. " in get_selected_index")
         return selected
      end

      function self:set_child_controller(control)
 	--print(selected .. " in set_child_controller")
         self.tab_controller = control
      end

      self.in_tab_group = false


      function self:move_selector(dir)
	--print(selected .. " in move_selector")
	--print(self:get_selected_index() .. " is in move_selector")
         --if you are already in the Tab sub group, pass the call down
         if(self.in_tab_group) then
            --print("self.in_tab_group true")
            self.tab_controller:move_selector(dir)
         --otherwise
         else
            --print("Customize move_selector()",dir[1],dir[2])
            table.foreach(dir, print)
            --move into the Tab sub group
            if dir[2] == 0 then
               if dir == Directions.RIGHT then
                  self.in_tab_group = true
                  view:enter_sub_group()
               end
            --move up and down through the tabs
            else
               local new_selected = selected + dir[2]
               --print("switching Tabs from",selected," to ",new_selected)
               if 1 <= new_selected and new_selected <= MenuSize then
                  selected = new_selected
                  --print(selected)
               end
               --MenuItemCallbacks[selected]()
               self:get_model():notify()
            end
         end
      end
   end)
