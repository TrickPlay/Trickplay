ProvidersCarouselController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.PROVIDER_SELECTION)
    local MenuItems = {
       DOMINOS = 1,
       PIZZA_HUT = 2,
       ROUND_TABLE = 3,
       PIZZA_MY_HEART = 4,
       PAPA_JOHNS = 5,
    }
    local MenuSize = 0
    for k, v in pairs(MenuItems) do
        MenuSize = MenuSize + 1
    end

    local selected = 1
    local MenuItemCallbacks = {
        [MenuItems.DOMINOS] =
           function(self)
              self:get_model():set_active_component(Components.FOOD_SELECTION)
              self:get_model():notify()
           end,
        [MenuItems.PIZZA_HUT] =
           function(self)
              self:get_model():set_active_component(Components.FOOD_SELECTION)
              self:get_model():notify()
           end,
        [MenuItems.ROUND_TABLE] =
           function(self)
              self:get_model():set_active_component(Components.FOOD_SELECTION)
              self:get_model():notify()
           end,
        [MenuItems.PIZZA_MY_HEART] =
           function(self)
              self:get_model():set_active_component(Components.FOOD_SELECTION)
              self:get_model():notify()
           end,
        [MenuItems.PAPA_JOHNS] =
           function(self)
              self:get_model():set_active_component(Components.FOOD_SELECTION)
              self:get_model():notify()
           end,

    }

    local CarouselKeyTable = {
        [keys.Left]  = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
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

    function self:move_selector(dir)
        screen:grab_key_focus()
        local new_selected = selected + dir[1]
        if 1 <= new_selected and new_selected <= MenuSize then
            selected = new_selected
        end
        self:get_model():notify()
    end

    function self:get_selected_index()
        return selected
    end		

    
    function self:run_callback()
        CarouselKeyTable[keys.Return](view)
    end
end)
