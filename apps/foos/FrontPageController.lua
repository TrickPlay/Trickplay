Directions = {
   RIGHT = { 1, 0},
   LEFT  = {-1, 0},
   DOWN  = { 0, 1},
   UP    = { 0,-1}
}


FrontPageController = Class(Controller, function(self, view, view_grid, ...)
    self._base.init(self, view, Components.FRONT_PAGE)

    -- the default selected index
    local selected = {1,1}
    local grid = view_grid

    function self:refresh_grid(g)
        grid = g
    end

    local MenuKeyTable = {
        [keys.Up]    = function(self) self:move_selector(Directions.UP) end,
        [keys.Down]  = function(self) self:move_selector(Directions.DOWN) end,
        [keys.Left]  = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
        [keys['r']]      = function(self) view.refresh() end,
        [keys.Return] = function(self) view.refresh() end    }


    function self:on_key_down(k)
        if MenuKeyTable[k] then
            MenuKeyTable[k](self)
        end
    end

    function self:reset_selected_index()
        selected = {1,1}
    end

    function self:get_selected_index()
        return selected
    end



    function self:move_selector(dir)
        local next_spot = {selected[1],selected[2]}

        --move to the next image (i.e. if the one you are on is 
        --not a 1x1 or the one you are moving to is not a 1x1)
        while grid[next_spot[1]]               ~= nil and
              grid[next_spot[1]][next_spot[2]] ~= nil and

              grid[next_spot[1]][next_spot[2]][1] == 
              grid[selected[1]][selected[2]][1]       and

              grid[next_spot[1]][next_spot[2]][2] == 
              grid[selected[1]][selected[2]][2]       do

            next_spot = {next_spot[1] + dir[2],
                         next_spot[2] + dir[1]}
        end

        --if you didn't reach an edge then, move to it
        if grid[next_spot[1]]               ~= nil and
           grid[next_spot[1]][next_spot[2]] ~= nil then
            selected[1] = grid[next_spot[1]][next_spot[2]][1]
            selected[2] = grid[next_spot[1]][next_spot[2]][2]
        end
        self:get_model():notify()

    end
end)
