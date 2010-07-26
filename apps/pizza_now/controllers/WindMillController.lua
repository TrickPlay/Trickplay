WindMillController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.CUSTOMIZE_ITEM)

    local CustomizeItems = {
        LEFT = 1,
        UP = 2,
        RIGHT = 3,
        DOWN = 4
    }
    
    local CustomSize = 0
    for k, v in pairs(CustomizeItems) do
        CustomSize = CustomSize + 1
    end

    -- the default selected index
    local selected = 0

    local CustomizeItemCallbacks = {
        [CustomizeItems.LEFT] = function(self)
        end,
        [CustomizeItems.UP] = function(self)
        end,
        [CustomizeItems.RIGHT] = function(self)
        end,
        [CustomizeItems.DOWN] = function(self)
            print("canceling")
        end
    }

    local CustomKeyTable = {
        [keys.Up]    = function(self) self:move_selector(CustomizeItems.UP) end,
        [keys.Down]  = function(self) self:move_selector(CustomizeItems.DOWN) end,
        [keys.Left]  = function(self) self:move_selector(CustomizeItems.LEFT) end,
        [keys.Right] = function(self) self:move_selector(CustomizeItems.RIGHT) end
    }

    function self:on_key_down(k)
        if CustomKeyTable[k] then
            CustomKeyTable[k](self)
        end
    end

    function self:get_selected_index()
        return selected
    end

    function self:move_selector(dir)
        selected = dir
        self:get_model():notify()
        selected = 0
    end

    function self:run_callback()
            local success, error_msg = pcall(CustomizeItemCallbacks[selected], self)
            if not success then print(error_msg) end
    end
end)
