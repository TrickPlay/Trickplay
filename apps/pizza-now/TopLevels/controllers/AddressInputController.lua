AddressInputController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.ADDRESS_INPUT)

    local model = view:get_model()

    local MenuItems = {
        STREET = 1,
        APT = 2,
        CITY = 3,
        ZIP = 4,
        CONFIRM = 5,
        EXIT = 6
    }
    local MenuSize = 0
    for k, v in pairs(MenuItems) do
        MenuSize = MenuSize + 1
    end

    -- the default selected index
    local selected = 1

    local function itemSelection(item, name)
        local textObject = view.entry_ui.children[item]
        textObject:grab_key_focus()
        function textObject:on_key_focus_out()
            self.on_key_focus_out = nil
            args = {}
            args[name] = self.text
            view:get_model():set_address(args)
        end
    end

    local MenuItemCallbacks = {
        [MenuItems.STREET] = function(self)
            itemSelection(MenuItems.STREET, "street")
            print("street selected")
        end,
        [MenuItems.APT] = function(self)
            itemSelection(MenuItems.APT, "apartment")
            print("apartment selected")
        end,
        [MenuItems.CITY] = function(self)
            itemSelection(MenuItems.CITY, "city")
            print("city selected")
        end,
        [MenuItems.ZIP] = function(self)
            itemSelection(MenuItems.ZIP, "zip")
            print("zip selected")
        end,
        [MenuItems.CONFIRM] = function(self)
            print("confirm?")
            --[[
            for k,v in pairs(model.address) do
                if(not model.address[k]) then
                    --TODO: Display this on screen
                    print("FORM NOT COMPLETE")
                    return
                end
            end
            --]]
            self:get_model():set_active_component(Components.PROVIDER_SELECTION)
            screen:show()
            self:get_model():notify()
        end,
        [MenuItems.EXIT] = function(self)
            print("exit?")
            exit()
        end
    }

    local AddressInputKeyTable = {
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
        if AddressInputKeyTable[k] then
            AddressInputKeyTable[k](self)
        end
    end

    function self:get_selected_index()
        return selected
    end

    function self:move_selector(dir)
        screen:grab_key_focus()
        local new_selected = selected + dir[2]
        if 1 <= new_selected and new_selected <= MenuSize then
            selected = new_selected
        end
        self:get_model():notify()
    end

end)
