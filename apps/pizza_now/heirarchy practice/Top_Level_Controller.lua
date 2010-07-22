Directions = {
   RIGHT = {1,0},
   LEFT = {-1,0},
   DOWN = {0,1},
   UP = {0,-1}
}

 TopLevelController = Class(Controller,
   function(self, view, ...)
      self._base.init(self, view, 1)

      local MenuItems = {
         HEADER = 1,
         CAR = 2,
         FOOTER = 3
      }
      local MenuSize = 0
      for k, v in pairs(MenuItems) do
         MenuSize = MenuSize + 1
      end
      
      self.h = header_view:get_controller()
      self.f = footer_view:get_controller()
      self.child = self.h
      -- the default selected index
      local selected = 1

      local MenuItemCallbacks = {
         [MenuItems.HEADER]=
            function(self)
               print("Header selected")
            end,
         [MenuItems.CAR] =
            function(self)
               print("Carousel selected")
            end,
         [MenuItems.FOOTER]=
            function(self)
               print("Footer selected")
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
         [keys.Up]    = function(self) self:move_selector(Directions.UP) end,
         [keys.Down]  = function(self) self:move_selector(Directions.DOWN) end,
         [keys.Left]  = function(self) self.child:move_selector(Directions.LEFT) end,
         [keys.Right] = function(self) self.child:move_selector(Directions.RIGHT) end,
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
         print("index:",selected)
         return selected
      end

      function self:move_selector(dir)
         table.foreach(dir, print)
         local new_selected = selected + dir[2]
         if 1 <= new_selected and new_selected <= MenuSize then
            selected = new_selected
         end
         MenuItemCallbacks[selected]()
         self:get_model():notify()
      end
   end)
