FrontPageController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.FRONT_PAGE)

    -- the default selected index
    local selected = {1,1}

    local MenuKeyTable = {
        [keys.Up]    = function(self) self:move_selector(Directions.UP) end,
        [keys.Down]  = function(self) self:move_selector(Directions.DOWN) end,
        [keys.Left]  = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
        [keys.Return] = function(self) 
            model.album_group:clear()
            model.albums = {}
            self:get_model():set_active_component(Components.SLIDE_SHOW)
            model.curr_slideshow = Slideshow:new { num_pics = 20, index = (model.front_page_index + (selected[2]-1))*2+(selected[1]-1)-1}
				--screen:clear()
	    model.curr_slideshow:begin()
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
        return selected[1],selected[2]
    end




    function self:move_selector(dir)
        local next_spot = {selected[1]+dir[2],selected[2]+dir[1]}
        if next_spot[1] > 0 and next_spot[1] <= NUM_ROWS and
           next_spot[2] > 0 and next_spot[2] <= NUM_VIS_COLS then

            selected[1] = next_spot[1]
            selected[2] = next_spot[2]
--[[
        elseif dir == Directions.RIGHT then
            view:move_right()
        elseif dir == Directions.LEFT  then
            view:move_left()
--]]
        elseif dir == Directions.RIGHT or dir == Directions.LEFT then
            view:shift_group(dir[1])
        end

        self:get_model():notify()

    end
end)
