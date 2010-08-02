ProviderFooterController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.PROVIDER_SELECTION)

    local MenuItems = {
        GO_BACK = 1,
        STREET = 2,
        CITY = 3,
        STATE = 4,
        ZIP = 5,
        CONTINUE = 6
    }
    
    local MenuSize = 0
    for k, v in pairs(MenuItems) do
        MenuSize = MenuSize + 1
    end

    -- the default selected index
    local selected = 1

    local function itemSelection(item, name)
        local textObject = view.ui.children[item]
        textObject.editable = true
        textObject:grab_key_focus()
        function textObject:on_key_focus_out()
            self.on_key_focus_out = nil
            args = {}
            args[name] = self.text
            view:get_model():set_address(args)
        end
    end

    local MenuItemCallbacks = {
        [MenuItems.GO_BACK] = function(self)
            print("Backing up")
            exit()
        end,
        [MenuItems.STREET] = function(self)
            itemSelection(MenuItems.STREET, "street")
        end,
        [MenuItems.CITY] = function(self)
            itemSelection(MenuItems.CITY, "city")
        end,
        [MenuItems.STATE] = function(self)
            itemSelection(MenuItems.STATE, "state")
        end,
        [MenuItems.ZIP] = function(self)
            itemSelection(MenuItems.ZIP, "zip")
        end,
        [MenuItems.CONTINUE] = function(self)
            print("continuing")
            self:get_model():set_active_component(Components.FOOD_SELECTION)
            self:get_model():notify()
        end
    }

    local MenuKeyTable = {
        --[keys.Up]    = function(self) self:move_selector(Directions.UP) end,
        --[keys.Down]  = function(self) self:move_selector(Directions.DOWN) end,
        [keys.Left]  = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
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

    function self:move_selector(dir)
        screen:grab_key_focus()
        local new_selected = selected + dir[1]
        if 1 <= new_selected and new_selected <= MenuSize then
            selected = new_selected
        end
        self:get_model():notify()
    end

    function self:run_callback()
            local success, error_msg = pcall(MenuItemCallbacks[selected], self)
            if not success then print(error_msg) end
    end
end)
