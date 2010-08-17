SourceManagerController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.SOURCE_MANAGER)

    -- the default selected index
    local selected = 1

    local MenuKeyTable = {
        [keys.Up]    = function(self) self:move_selector(Directions.UP) end,
        [keys.Down]  = function(self) self:move_selector(Directions.DOWN) end,
        [keys.Left]  = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
        [keys.Return] = function(self) 

        end
    }


    function self:on_key_down(k)
        if MenuKeyTable[k] then
            MenuKeyTable[k](self)
        end
    end

    function self:reset_selected_index()
        selected = 1
    end

    function self:set_selected_index(i)
        selected = i
    end

    function self:get_selected_index()
        return selected
    end




    function self:move_selector(dir)
        local next_spot = selected+dir[2]
        if next_spot > 0 and next_spot <= #view.menu_items then

            selected = next_spot
        end
        self:get_model():notify()

    end
end)
