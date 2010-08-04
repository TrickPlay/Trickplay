DeliveryOptionsController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.PROVIDER_SELECTION)

    local Options = {
        DELIVERY_OR_PICKUP = 1,
        ARRIVAL_TIME = 2,
        SORT = 3
    }
    local OptionSize = 0
    for k, v in pairs(Options) do
        OptionSize = OptionSize + 1
    end

    -- the default selected index
    local selected = 1

    local OptionCallbacks = {
        [Options.DELIVERY_OR_PICKUP] = function(self)
            print("delivery or pickup selected")
            self:get_model():set_delivery()
            self:get_model():notify()
        end,
        [Options.ARRIVAL_TIME] = function(self)
            print("arrival time selected")
            self:get_model():set_arrival_time()
            self:get_model():notify()
        end,
        [Options.SORT] = function(self)
            print("sort selected")
            self:get_model():notify()
        end
    }

    local OptionsInputKeyTable = {
        [keys.Left] = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
        [keys.Return] =
        function(self)
            -- compromise so that there's not a full-on lua panic,
            -- but the error message still displays on screen
            local success, error_msg = pcall(OptionCallbacks[selected], self)
            if not success then print(error_msg) end
        end
    }

    function self:on_key_down(k)
        if OptionsInputKeyTable[k] then
            OptionsInputKeyTable[k](self)
        end
    end

    function self:get_selected_index()
       return selected
    end

    function self:move_selector(dir)
        local new_selected = selected + dir[1]
        if 1 <= new_selected and new_selected <= OptionSize then
            selected = new_selected
        end
        self:get_model():notify()
    end

    function self:run_callback()
        local success, error_msg = pcall(OptionCallbacks[selected], self)
        if not success then print(error_msg) end
    end

end)