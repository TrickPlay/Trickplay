ProviderSelectionController = Class(Controller,
   function(self, view, ...)
      self._base.init(self, view, Components.PROVIDER_SELECTION)

      local MenuItems = {
          DOMINOS_1 = 1,
          DOMINOS_2 = 2,
          DOMINOS_3 = 3,
          PIZZA_HUT = 4,
          GO_BACK = 5
      }
      local MenuSize = 0
      for k, v in pairs(MenuItems) do
         MenuSize = MenuSize + 1
      end

      -- the default selected index
      local selected = 1

      local MenuItemCallbacks = {
         [MenuItems.DOMINOS_1]=
            function(self)
               print("dominos selected")
            end,
         [MenuItems.DOMINOS_2]=
            function(self)
               print("dominos! selected")
            end,
         [MenuItems.DOMINOS_3]=
            function(self)
               print("dominos :) selected")
            end,
         [MenuItems.PIZZA_HUT]=
            function(self)
               print("pizza hut selected")
            end,
         [MenuItems.GO_BACK]=
            function(self)
               print("go back?")
            end
      }
      
      local ProviderInputKeyTable = {
         [keys.Up] = function(self) self:move_selector(Directions.UP) end,
         [keys.Down] = function(self) self:move_selector(Directions.DOWN) end,
         [keys.Left] = function(self) self:move_selector(Directions.LEFT) end,
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
         if ProviderInputKeyTable[k] then
            ProviderInputKeyTable[k](self)
         end
      end

      function self:get_selected_index()
         return selected
      end

      function self:move_selector(dir)
         table.foreach(dir, print)
         local new_selected = selected + dir[2]
         if 1 <= new_selected and new_selected <= MenuSize then
            selected = new_selected
         end
         print("selected: "..selected)
         MenuItemCallbacks[selected]()
         self:get_model():notify()
      end

   end)
