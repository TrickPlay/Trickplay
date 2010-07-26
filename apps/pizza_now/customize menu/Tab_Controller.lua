Directions = {
   RIGHT = {1,0},
   LEFT = {-1,0},
   DOWN = {0,1},
   UP = {0,-1}
}

TabController = Class(Controller,
   function(self, view, ...)
      self._base.init(self, view, Component.TAB)
--[[
      local MenuItems = {}
      for i,opt in ipairs(view.menu_items) do
         MenuItems[opt] = i
      end
      local MenuSize = #view.menu_items
--]]

      -- the default selected index
      local selected = 1
--[[
      local MenuItemCallbacks = {}
      for opt,i in pairs(MenuItems) do
         MenuItemCallbacks[i] = 
            function(self)
               --print(opt.." selected")
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
         [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end
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
	--print("tab_controller on_key_down")
         if MenuKeyTable[k] then
            MenuKeyTable[k](self)
         end
      end

      function self:get_selected_index()
         --print("\tTab index:",selected)
         return selected
      end
      function self:reset_selected_index()
         --print("\tTab index:",selected)
         selected = 1
      end
      --local curr_tab_num = 0

      function self:move_selector(dir)
--[[
         if curr_tab_num ~= customize_view:get_controller():get_selected_index() then
             curr_tab_num = customize_view:get_controller():get_selected_index()
             selected = 1
         end
--]]
         --print("Tab move_selector()", dir[1], dir [2])
         table.foreach(dir, print)
         --move out of the Tab sub group
         if dir == Directions.LEFT then
            customize_view:get_controller().in_tab_group = false
            view:leave_sub_group()
         --move up and down through the options
         elseif dir[2] ~= 0 then
            --print("\tTab move_selector(): moving Up and DOwn")
            local new_selected = selected + dir[2]
            if 1 <= new_selected and new_selected <= #view.menu_items[customize_view:get_controller():get_selected_index()] then
               selected = new_selected
            end
            --MenuItemCallbacks[selected]()
            self:get_model():notify()
         end
         
      end
   end)
