ProviderSelectionController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.PROVIDER_SELECTION)

    local ProviderGroups = {
        DELIVERY_OPTIONS = 1,
        PROVIDERS = 2,
        GO_BACK = 3
    }

    local GroupSize = 0
    for k, v in pairs(ProviderGroups) do
        GroupSize = GroupSize + 1
    end

    -- the default selected index
    local selected = 1

    local ProviderCallbacks = {
        [ProviderGroups.DELIVERY_OPTIONS] = function(self)
            print("delivery options")
        end,
        [ProviderGroups.PROVIDERS] = function(self)
            print("providers")
        end,
        [ProviderGroups.GO_BACK] = function(self)
            print("go back?")
        end
    }

    local ProviderInputKeyTable = {
        [keys.Up] = function(self) self:move_selector(Directions.UP) end,
        [keys.Down] = function(self) self:move_selector(Directions.DOWN) end,
        [keys.Left] = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
        [keys.Return] = function(self)
            -- compromise so that there's not a full-on lua panic,
            -- but the error message still displays on screen
            local success, error_msg = pcall(ProviderCallbacks[selected], self)
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
        if 1 <= new_selected and new_selected <= GroupSize then
            selected = new_selected
        end
        print("selected: "..selected)
        ProviderCallbacks[selected]()
        self:get_model():notify()
    end

end)
