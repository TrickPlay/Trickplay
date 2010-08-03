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
    --[=[
          MenuItemCallbacks[MenuItems["Back"]] = function()
              self:get_model():set_active_component(Components.FOOD_SELECTION)
              self:get_model():notify()
          end

          MenuItemCallbacks[MenuItems["Add"]] = function()
             --cart[#cart + 1] = pizza
             self:get_model():set_active_component(Components.FOOD_SELECTION)
             self:get_model():notify()
          end
    --]=]
          self:reset_selected_index()
      end

      local MenuKeyTable = {
         [keys.Up]    = function(self) self:move_selector(Directions.UP) end,
         [keys.Down]  = function(self) self:move_selector(Directions.DOWN) end,
         [keys.Left]  = function(self) self:move_selector(Directions.LEFT) end,
         [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
         
         [keys.Return] =
            function(self)
               local model = self:get_model()
                if self.on_back_arrow then
                    self.selected = 1
                    self.on_back_arrow = false
                    model.current_item.pizzagroup:hide_all()
                    model:set_active_component(Components.FOOD_SELECTION)
                    model:notify()
                elseif self.add_to_order then
                    self.selected = 1
                    self.add_to_order = false
                    model.current_item.pizzagroup:hide_all()
                    if model.current_item_is_in_cart == false then
                       model.cart[#self:get_model().cart + 1] = view:get_model().current_item
                    end

                    if NETWORKING then
                       Navigator:add_pizza(model.current_item:as_dominos_pizza())
                       local total, price = Navigator:get_total()
                       print("\n\n\n\n\n\n\n\n\n\n" ..
                             "Current Total: $" .. tostring(total) .. "\n" ..
                             "Price of just-added pizza: $" .. tostring(price) .. "\n" ..
                             "\n\n\n\n\n\n\n\n\n")
                       if price then
                          model.current_item.Price = "$" .. tostring(price)
                       end
                    end
                    self:get_model():set_active_component(Components.FOOD_SELECTION)
                    print("size of cart",#self:get_model().cart)
                    print(self:get_model().cart[1].Name)
                    self:get_model():notify()
                end
            end
         
      }

      function self:update_field(cov,place)
         assert(self:get_model():get_active_component() == Components.CUSTOMIZE_ITEM,
                                  "updating a field when not in customize item mode")
         local topping_index = self:get_model():get_controller(Components.TAB):get_selected_index()
         local topping = self:get_model().current_item.Tabs[selected].Options[topping_index]
         topping.CoverageX = cov
         topping.Placement = place
         
         topping.ToppingGroup = topping_dropping(topping.Image, place, cov, topping.ToppingGroup, self:get_model().current_item.pizzagroup)

         view.sub_group_items[selected][topping_index][2]:unparent()
         view.sub_group_items[selected][topping_index][3]:unparent()

         view.sub_group_items[selected][topping_index][3] = Image {
             position = {-70*(3-1), 60*(topping_index-1)},
             src      = "assets/Placement/"..All_Options.Placement_r[place]..".png"
         }
         view.sub_group[selected]:add(view.sub_group_items[selected][topping_index][3])

         view.sub_group_items[selected][topping_index][2] = Image {
             position = {-70*(2-1), 60*(topping_index-1)},
             src      = "assets/CoverageX/"..All_Options.CoverageX_r[cov]..".png"
         }
         view.sub_group[selected]:add(view.sub_group_items[selected][topping_index][2])
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
         print("\n\n\nSetting child controller")
         assert(control,"trying to set tab controller in customize controller to be nil")
 	--print(selected .. " in set_child_controller")
         self.tab_controller = control
      end
      function self:reset_selected_index()
         selected = 1
      end

      self.in_tab_group  = false
      self.on_back_arrow = false
      self.add_to_order  = false


      function self:move_selector(dir)
         if(self.on_back_arrow) then
            if dir == Directions.RIGHT then
               self.on_back_arrow = false
               self:get_model():notify()
            end
         --if you are already in the Tab sub group, pass the call down
         elseif(self.in_tab_group) then
            --print("self.in_tab_group true")
            assert(self.tab_controller,"tab controller is nil")
            self.tab_controller:move_selector(dir)
         elseif self.add_to_order then
            if dir == Directions.UP then
                self.add_to_order = false
                self:get_model():notify()
            elseif dir == Directions.LEFT then
                self.on_back_arrow = true
                self.add_to_order  = false
                self:get_model():notify()
            end
         --otherwise
         else
            --print("Customize move_selector()",dir[1],dir[2])
            --table.foreach(dir, print)
            --move into the Tab sub group
            if dir[2] == 0 then
               if dir == Directions.RIGHT and view:get_model().current_item.Tabs[selected].Options ~= nil then
                  self.in_tab_group = true
                  view:enter_sub_group()
               elseif dir == Directions.LEFT then
                  self.on_back_arrow = true
                  self:get_model():notify()
               end
            --move up and down through the tabs
            else
               local new_selected = selected + dir[2]
               print(new_selected, MenuSize)
               --print("switching Tabs from",selected," to ",new_selected)
               if 1 <= new_selected and new_selected <= MenuSize then
                  selected = new_selected
                  --print(selected)
               elseif new_selected > MenuSize then
                  print("add??")
                  self.add_to_order = true
                  self:get_model():notify()
               end
               --MenuItemCallbacks[selected]()
               self:get_model():notify()
            end
         end
      end
   end)
