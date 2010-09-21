Directions = {
   RIGHT = {1,0},
   LEFT = {-1,0},
   DOWN = {0,1},
   UP = {0,-1}
}

 HeaderController = Class(Controller,
   function(self, view, ...)
      self._base.init(self, view, 1)

      local MenuItems = {
         PIZZA = 1,
         SANDWICHES = 2,
         BREAD = 3,
         WHORE = 4
      }
      local MenuSize = 0
      for k, v in pairs(MenuItems) do
         MenuSize = MenuSize + 1
      end

      -- the default selected index
      local selected = 1

      local MenuItemCallbacks = {
         [MenuItems.PIZZA]=
            function(self)
               print("Pizza selected")
            end,
         [MenuItems.SANDWICHES]=
            function(self)
               print("Sandwiches selected")
            end,
         [MenuItems.BREAD]=
            function(self)
               print("Bread selected")
            end,
         [MenuItems.WHORE]=
            function(self)
               print("Ze Mark uv ze whore")
            end
      }

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
         --[keys.Up]    = function(self) self:move_selector(Directions.UP) end,
         --[keys.Down]  = function(self) self:move_selector(Directions.DOWN) end,
         [keys.Left]  = function(self) self:move_selector(Directions.LEFT) end,
         [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
         [keys.Return] =
            function(self)
               -- compromise so that there's not a full-on lua panic,
               -- but the error message still displays on screen
               local success, error_msg = pcall(MenuItemCallbacks[selected], self)
               if not success then print(error_msg) end
            end
      }

      function self:on_key_down(k)
         if MenuKeyTable[k] then
            MenuKeyTable[k](self)
         end
      end

      function self:get_selected_index()
         print("\tHeader index:",selected)
         return selected
      end

      function self:move_selector(dir)
         table.foreach(dir, print)
         local new_selected = selected + dir[1]
         if 1 <= new_selected and new_selected <= MenuSize then
            selected = new_selected
         end
         MenuItemCallbacks[selected]()
         self:get_model():notify()
      end
   end)
