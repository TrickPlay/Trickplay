FinalFooterController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.CHECKOUT)

    local MenuItems = {
        PLACE_ORDER = 1
    }
    
    local MenuSize = 0
    for k, v in pairs(MenuItems) do
        MenuSize = MenuSize + 1
    end

    -- the default selected index
    local selected = 1

    local MenuItemCallbacks = {
        [MenuItems.PLACE_ORDER] = function(self)
            print("continuing")
            self:get_model():set_active_component(Components.FOOD_SELECTION)
            self:get_model():notify()
        end
    }

    local MenuKeyTable = {
        [keys.Up]    = function(self) self:move_selector(Directions.UP) end,
        [keys.Return] = function(self)
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
        return selected
    end

    function self:set_parent_controller(parent_controller)
        print("\n\n\nhere\n\n\n")
        self.parent_controller = parent_controller
    end

    function self:move_selector(dir)
        if(not self.parent_controller) then
            self:set_parent_controller(view.parent_view:get_controller())
        end
        self.parent_controller:move_selector(dir)
        self:get_model():notify()
    end

    function self:run_callback()
            local success, error_msg = pcall(MenuItemCallbacks[selected], self)
            if not success then print(error_msg) end
    end
end)
