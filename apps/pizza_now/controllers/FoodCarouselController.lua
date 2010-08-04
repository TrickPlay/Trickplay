FoodCarouselController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.FOOD_SELECTION)
    local MenuItems = {
       BUILD_PIZZA = 1,
       SIDES = 2,
       DRINKS = 3,
       YOUR_MOM = 4,
       ANOTHER_CHOICE = 5,
       CHICKEN = 6,
    }
    local MenuSize = 0
    for k, v in pairs(MenuItems) do
        MenuSize = MenuSize + 1
    end

    local selected = 1
    local MenuItemCallbacks = {
        [MenuItems.BUILD_PIZZA] =
           function(self)
              self:get_model().current_item = EmptyPizza()
              self:get_model().current_item.Name = "Pizza"
              self:get_model().current_item_is_in_cart = false
              self:get_model():set_active_component(Components.CUSTOMIZE)
              self:get_model():get_active_controller():init_shit()
              self:get_model():get_controller(Components.TAB):init_shit()
              self:get_model():notify()
           end,
        [MenuItems.SIDES] =
           function(self)
              self:get_model().current_item = EmptyPizza()
              self:get_model().current_item.Name = "Pizza"
              self:get_model().current_item_is_in_cart = false
              self:get_model():set_active_component(Components.CUSTOMIZE)
              self:get_model():get_active_controller():init_shit()
              self:get_model():get_controller(Components.TAB):init_shit()
              self:get_model():notify()
           end,
        [MenuItems.DRINKS] =
           function(self)
              self:get_model().current_item = EmptyPizza()
              self:get_model().current_item.Name = "Pizza"
              self:get_model().current_item_is_in_cart = false
              self:get_model():set_active_component(Components.CUSTOMIZE)
              self:get_model():get_active_controller():init_shit()
              self:get_model():get_controller(Components.TAB):init_shit()
              self:get_model():notify()
           end,
        [MenuItems.YOUR_MOM] =
           function(self)
              self:get_model().current_item = EmptyPizza()
              self:get_model().current_item.Name = "Pizza"
              self:get_model().current_item_is_in_cart = false
              self:get_model():set_active_component(Components.CUSTOMIZE)
              self:get_model():get_active_controller():init_shit()
              self:get_model():get_controller(Components.TAB):init_shit()
              self:get_model():notify()
           end,
        [MenuItems.ANOTHER_CHOICE] =
           function(self)
              self:get_model().current_item = EmptyPizza()
              self:get_model().current_item.Name = "Pizza"
              self:get_model().current_item_is_in_cart = false
              self:get_model():set_active_component(Components.CUSTOMIZE)
              self:get_model():get_active_controller():init_shit()
              self:get_model():get_controller(Components.TAB):init_shit()
              self:get_model():notify()
           end,
        [MenuItems.CHICKEN] =
           function(self)
              self:get_model().current_item = EmptyPizza()
              self:get_model().current_item.Name = "Pizza"
              self:get_model().current_item_is_in_cart = false
              self:get_model():set_active_component(Components.CUSTOMIZE)
              self:get_model():get_active_controller():init_shit()
              self:get_model():get_controller(Components.TAB):init_shit()
              self:get_model():notify()
           end,
    }

    local CarouselKeyTable = {
        [keys.Left]   = function(self) self:move_selector(Directions.LEFT)  end,
        [keys.Right]  = function(self) self:move_selector(Directions.RIGHT) end,
       
        [keys.Return] =
        function(self)
            local success, error_msg = pcall(MenuItemCallbacks[selected], self)
            if not success then print(error_msg) end
        end
    }

    function self:on_key_down(k)
        if CarouselKeyTable[k] then
           CarouselKeyTable[k](self)
        end
    end

    function self:get_selected_index()
        return selected
    end		

    function self:move_selector(dir)
       print("FoodCarouselController: move_selector called, selected is currently", selected)
       screen:grab_key_focus()
       local new_selected = selected + dir[1]
       if 1 <= new_selected and new_selected <= MenuSize then
          selected = new_selected
       end
       print("FoodCarouselController: exiting move_selector, selected is now", selected)
       self:get_model():notify()
    end
end)
