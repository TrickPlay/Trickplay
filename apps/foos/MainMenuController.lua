


MainMenuController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.MAIN_MENU)

    -- the default selected index
    local selected = 1

    local MenuItemCallbacks = {
        --Add Source
        function()
        end,

        --Resume
        function()
            self:get_model():set_active_component(Components.FRONT_PAGE)
            self:get_model():notify()
        end,

        --Exit
        function()
            exit()
        end
    }

    local MenuKeyTable = {
        [keys.Up]    = function(self) self:move_selector(Directions.UP) end,
        [keys.Down]  = function(self) self:move_selector(Directions.DOWN) end,
        [keys.Left]  = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,

        [keys.Return] = function(self) MenuItemCallbacks[selected]() end
    }


    function self:on_key_down(k)
        if MenuKeyTable[k] then
            MenuKeyTable[k](self)
        end
    end

    function self:reset_selected_index()
        selected = 1
    end

    function self:get_selected_index()
        return selected
    end



    function self:move_selector(dir)
        if dir == Directions.DOWN then
            self:get_model():set_active_component(Components.FRONT_PAGE)
        else
            local new_selected = selected + dir[1]
            if new_selected > 0 and new_selected <= #view.menu_items then
                selected = new_selected
            end
        end
        self:get_model():notify()
    end
end)
