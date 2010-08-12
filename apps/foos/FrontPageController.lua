Directions = {
   RIGHT = { 1, 0},
   LEFT  = {-1, 0},
   DOWN  = { 0, 1},
   UP    = { 0,-1}
}


FrontPageController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.FRONT_PAGE)

    -- the default selected index
    local selected = {1,1}
    local prev_index = {1,1}

    local MenuKeyTable = {
        [keys.Up]    = function(self) self:move_selector(Directions.UP) end,
        [keys.Down]  = function(self) self:move_selector(Directions.DOWN) end,
        [keys.Left]  = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
        [keys.Return] = function(self) 
            self:get_model():set_active_component(Components.ITEM_SELECTED)
            self:get_model():notify()
        end
    }


    function self:on_key_down(k)
        if MenuKeyTable[k] then
            MenuKeyTable[k](self)
        end
    end

    function self:reset_selected_index()
        selected = {1,1}
    end

    function self:set_selected_index(r,c)
        selected = {r,c}
    end

    function self:get_selected_index()
        return selected
    end

    function self:get_prev_index()
        return prev_index
    end
    function self:set_prev_index(r,c)
        prev_index = {r,c}
    end



    function self:move_selector(dir)
        prev_index = {selected[1],selected[2]}
        local next_spot = {selected[1]+dir[2],selected[2]+dir[1]}
        if model.vis_pics[next_spot[1]]               ~= nil and
           model.vis_pics[next_spot[1]][next_spot[2]] ~= nil then

            selected[1] = next_spot[1]
            selected[2] = next_spot[2]
        elseif dir == Directions.RIGHT then
            view:move_right()
        elseif dir == Directions.LEFT  then
            view:move_left()
        end

        self:get_model():notify()

    end
end)
