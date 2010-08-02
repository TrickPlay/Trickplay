FinalOrderController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.CHECKOUT)

    local model = self.model

    local Options = {
        EDIT_ORDER = 1,
        ADD_COUPON = 2
    }
    local OptionSize = 0
    for k, v in pairs(Options) do
        OptionSize = OptionSize + 1
    end

    -- the default selected index
    local selected = 1

    local OptionCallbacks = {
        [Options.EDIT_ORDER] = function(self)
            print("edit order")
            model:set_active_component(Components.FOOD_SELECTION)
            model:notify()
        end,
        [Options.ADD_COUPON] = function(self)
            print("adding coupon")
        end
    }

    local OptionsInputKeyTable = {
        [keys.Up] = function(self) self:move_selector(Directions.UP) end,
        [keys.Down] = function(self) self:move_selector(Directions.DOWN) end,
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

    function self:set_parent_controller(parent_controller)
        self.parent_controller = parent_controller
    end

    function self:move_selector(dir)
        if(not self.parent_controller) then
            self:set_parent_controller(view.parent_view:get_controller())
        end
        if(0 ~= dir[2]) then
            local new_selected = selected + dir[2]
            if(1 <= new_selected and new_selected <= OptionSize) then
                selected = new_selected
            elseif(new_selected == OptionSize + 1) then
                --change focus to footer
                self.parent_controller:move_selector(dir)
            end
        elseif(0 ~= dir[1]) then
            --change focus to credit info
            self.parent_controller:move_selector(dir)
        else
            error("something sucks")
        end
        self:get_model():notify()
    end

    function self:run_callback()
        local success, error_msg = pcall(OptionCallbacks[selected], self)
        if not success then print(error_msg) end
    end

end)
