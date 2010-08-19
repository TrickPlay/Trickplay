FrontPageController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.FRONT_PAGE)

    -- the default selected index
    local selected = {1,1}
    local MenuKeyTable = {
        [keys.Up]    = function(self) self:move_selector(Directions.UP) end,
        [keys.Down]  = function(self) self:move_selector(Directions.DOWN) end,
        [keys.Left]  = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
        [keys.a]     = function(self)
            self:get_model():set_active_component(Components.SOURCE_MANAGER)
            view.timer:stop()
            self:get_model():notify()

        end,
        [keys.d]     = function(self)
            local formula = (model.front_page_index + (selected[2]-1))*2+(selected[1]-1)-1
				deleteAdapter(formula)

        end,

        [keys.Return] = function(self) 
            local formula = (model.front_page_index + (selected[2]-1))*2+
                                                     (selected[1]-1)-1
            if adapters[formula] ~= nil then
                model.album_group:clear()
                model.albums = {}
                self:get_model():set_active_component(Components.SLIDE_SHOW)
                model.curr_slideshow = Slideshow:new{ 
                    num_pics = 20, 
                    index    = #adapters+1 - formula
                }
                view.timer:stop()
                self:get_model():notify()
			       model.curr_slideshow:begin()
            end
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

        elseif dir == Directions.RIGHT or dir == Directions.LEFT then
            local next_index = model.front_page_index + dir[1]
            local upper_bound = math.ceil(#adapters / NUM_ROWS) -
                                     (NUM_VIS_COLS-1)

            if next_index > 0 and next_index <= upper_bound then
                model.front_page_index = next_index
            end
        end
        self:get_model():notify()

    end
end)
