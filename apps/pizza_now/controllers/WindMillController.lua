WindMillController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.CUSTOMIZE_ITEM)

    local amountSelection = false
    local topping = {
        amount = 0,
        side = 0
    }

    local Amount = {
      NONE    = 1,
      LIGHT   = 2,
      NORMAL = 3,
      EXTRA   = 4
    }

    local Side = {
       NONE   = 1,
       LEFT   = 2,
       RIGHT  = 3,
       WHOLE = 4
    }

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
            if(not amountSelection) then
                topping.side = Side.LEFT
                amountSelection = true
            else
                topping.amount = Amount.LIGHT
                amountSelection = false
                self:get_model():get_controller(Components.CUSTOMIZE):update_field(topping.amount,topping.side)
                self:get_model():set_active_component(Components.TAB)
                self:get_model():notify()
            end
        end,
        [CustomizeItems.UP] = function(self)
            if(not amountSelection) then
                topping.side = Side.WHOLE
                amountSelection = true
            else
                topping.amount = Amount.NORMAL
                amountSelection = false
                self:get_model():get_controller(Components.CUSTOMIZE):update_field(topping.amount,topping.side)
                self:get_model():set_active_component(Components.TAB)
                self:get_model():notify()
            end
        end,
        [CustomizeItems.RIGHT] = function(self)
            if(not amountSelection) then
                topping.side = Side.RIGHT
                amountSelection = true
            else
                topping.amount = Amount.EXTRA
                amountSelection = false
                self:get_model():get_controller(Components.CUSTOMIZE):update_field(topping.amount,topping.side)
                self:get_model():set_active_component(Components.TAB)
                self:get_model():notify()
            end
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
        self:run_callback()
        self:get_model():notify()
        selected = 0
    end

    function self:run_callback()
            local success, error_msg = pcall(CustomizeItemCallbacks[selected], self)
            if not success then print(error_msg) end
    end
end)
