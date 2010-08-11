


HelpMenuController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.HELP_MENU)

    -- the default selected index
    local selected = 1

    local MenuKeyTable = {
        [keys.Up]    = function(self) self:get_model():notify() end,
        [keys.Down]  = function(self) self:get_model():notify() end,
        [keys.Left]  = function(self) self:get_model():notify() end,
        [keys.Right] = function(self) self:get_model():notify() end,

        [keys.Return] = function(self) 
            self:get_model():set_active_component(Components.FRONT_PAGE)
            self:get_model():notify()
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

    function self:get_selected_index()
        return selected
    end



    function self:move_selector(dir)
        self:get_model():notify()
    end
end)
