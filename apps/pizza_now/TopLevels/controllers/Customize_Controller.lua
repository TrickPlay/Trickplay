CustomizeController = Class(Controller,
   function(self, view, ...)
      self._base.init(self, view, Components.CUSTOMIZE)

      -- the default selected index
      local selected = 1

      local MenuItems = {}
      local MenuItemCallbacks = {}
      local MenuSize = 0
      
      function self:init_shit()
          view:Create_Menu_Items()

          MenuItems = {}
          MenuItemCallbacks = {}
          for i,opt in ipairs(self:get_model().current_item.Tabs) do
             MenuItems[opt.Tab_Text] = i
             MenuItemCallbacks[i] = 
                function(self)
                   print(opt.Tab_Text.." selected")
                end
          end
          MenuSize = #view:get_model().current_item.Tabs
    
          MenuItemCallbacks[MenuItems["Go Back"]] = function()
              self:get_model():set_active_component(Components.FOOD_SELECTION)
              self:get_model():notify()
          end

          MenuItemCallbacks[MenuItems["Add to Order"]] = function()
             --cart[#cart + 1] = pizza
             self:get_model():set_active_component(Components.FOOD_SELECTION)
             self:get_model():notify()
          end
          self:reset_selected_index()
      end

      local MenuKeyTable = {
         [keys.Up]    = function(self) self:move_selector(Directions.UP) end,
         [keys.Down]  = function(self) self:move_selector(Directions.DOWN) end,
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

      function update_field(cov,place)
         assert(self:get_model():get_active_component() == Components.CUSTOMIZE_ITEM,
                                  "updating a field when not in customize item mode")
         local topping_index = self:get_model():get_controller(Components.TAB):get_selected_index()
         local topping = self:get_model().current_item.Tabs[selected].Options[topping_index]
         topping.CoverageX = cov
         topping.Placement = place
         view.ui:unparent(view.sub_group_items[selected][topping_index][2])
         view.ui:unparent(view.sub_group_items[selected][topping_index][3])
         view.sub_group_items[selected][topping_index][2] = Text {
                        position = {0, 60*(opt_index-1)},
                        font     = DEFAULT_FONT,
                        color    = DEFAULT_COLOR,
                        text     = place
                    }
view.sub_group[tab_index]:add(view.sub_group_items[tab_index][opt_index][2])
         view.sub_group_items[selected][topping_index][3] = Text {
                        position = {0, 60*(opt_index-1)},
                        font     = DEFAULT_FONT,
                        color    = DEFAULT_COLOR,
                        text     = cov
                    }
view.sub_group[tab_index]:add(view.sub_group_items[tab_index][opt_index][3])
      end

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
        function self:reset_selected_index()
            selected = 1
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
            --table.foreach(dir, print)
            --move into the Tab sub group
            if dir[2] == 0 then
               if dir == Directions.RIGHT and view:get_model().current_item.Tabs[selected].Options ~= nil then
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
