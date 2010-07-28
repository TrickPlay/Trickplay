CheckoutController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.CHECKOUT)

    local MenuItems = {
        STREET = 1,
        APT = 2,
        CITY = 3,
        ZIP = 4,
        CARD_TYPE = 5,
        CARD_NUMBER = 6,
        CARD_CODE = 7,
        CARD_EXPIRATION = 8,
        CONFIRM = 9,
        GO_BACK = 10
    }
    local MenuSize = 0
    for k, v in pairs(MenuItems) do
        MenuSize = MenuSize + 1
    end

    -- the default selected index
    local selected = 1

    local MenuItemCallbacks = {
        [MenuItems.STREET] = function(self)
            view.ui.children[MenuItems.STREET]:grab_key_focus()
            print("street selected")
        end,
        [MenuItems.APT] = function(self)
            view.ui.children[MenuItems.APT]:grab_key_focus()
            print("apartment selected")
        end,
        [MenuItems.CITY] = function(self)
            view.ui.children[MenuItems.CITY]:grab_key_focus()
            print("city selected")
        end,
        [MenuItems.ZIP] = function(self)
            view.ui.children[MenuItems.ZIP]:grab_key_focus()
            print("zip selected")
        end,
        [MenuItems.CARD_TYPE] = function(self)
        end,
        [MenuItems.CARD_NUMBER] = function(self)
        end,
        [MenuItems.CARD_CODE] = function(self)
        end,
        [MenuItems.CARD_EXPIRATION] = function(self)
        end,
        [MenuItems.CONFIRM] = function(self)
            print("confirm?")
        end,
        [MenuItems.GO_BACK] = function(self)
            print("exit?")
            self:get_model():set_active_component(Components.PROVIDER_SELECTION)
            self:get_model():notify()
        end
    }

    local CheckoutKeyTable = {
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
        if CheckoutKeyTable[k] then
            CheckoutKeyTable[k](self)
        end
    end

    function self:get_selected_index()
        return selected
    end

    function self:move_selector(dir)
        screen:grab_key_focus()
        table.foreach(dir, print)
        local new_selected = selected + dir[2]
        if 1 <= new_selected and new_selected <= MenuSize then
            selected = new_selected
        end
        self:get_model():notify()
    end

end)
