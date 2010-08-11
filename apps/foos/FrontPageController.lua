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
        [keys.r]     = function(self) view.refresh() end,
        [keys.h]     = function(self)
            self:get_model():set_active_component(Components.HELP_MENU)
            self:get_model():notify()
 end,

        [keys.m]     = function(self)
            self:get_model():set_active_component(Components.MAIN_MENU)
            self:get_model():notify() 
        end,

        [keys.Return] = function(self) 
            --text goes on left side if too close to the right
            if selected[2] > NUM_COLS/2+1 then
                self:get_model().pic_text = {
                         (selected[2]-1)*screen.width/NUM_COLS - 250,
                         (selected[1]-1)*screen.height/NUM_ROWS
                }
                print("text left",self:get_model().pic_text[1],self:get_model().pic_text[2])

            --defaults the the right otherwise
            else
                self:get_model().pic_text = {
                         (selected[2]-1)*screen.width/NUM_COLS +
                         view.menu_items[selected[1]][selected[2]].width*
                         view.menu_items[selected[1]][selected[2]].scale[1]+20,
                         (selected[1]-1)*screen.height/NUM_ROWS
                }
                print("text right",self:get_model().pic_text[1],self:get_model().pic_text[2])

            end
            --self:get_model().selected_picture = {selected[1],selected[2]}
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



    function self:move_selector(dir)
        local next_spot = {selected[1],selected[2]}


        --Pressing up when you are on the top row of images
        --brings the upper menu
        if next_spot[1] + dir[2] == 0 then
            self:get_model():set_active_component(Components.MAIN_MENU)       


        --Regular movement/navigation within the picture grid
        else
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

        end

        self:get_model():notify()

    end
end)
