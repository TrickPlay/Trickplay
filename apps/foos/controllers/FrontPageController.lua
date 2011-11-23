FrontPageController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.FRONT_PAGE)

    -- the default selected index

    local selected = {1,1}
    local MenuKeyTable = {
        [keys.Up]    = function(self) self:move_selector(Directions.UP)    end,
        [keys.Down]  = function(self) self:move_selector(Directions.DOWN)  end,
        [keys.Left]  = function(self) self:move_selector(Directions.LEFT)  end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
--[[
        [keys.a]     = function(self)
            self:get_model():set_active_component(Components.SOURCE_MANAGER)
            self:get_model():notify()
        end,
        [keys.d]     = function(self)
            print("num left",#adapters)
            if #adapters > 1 then
                print("entered")
                view:Delete_Cover(model.fp_1D_index)--formula)
            else
                print("didnt")
                reset_keys()            
            end
        end,
        [keys.s] = function(self)
            if style == #slideshow_styles then
                style = 1
            else
                style = style + 1
            end
            print (slideshow_styles[style])
            reset_keys()            
        end,
--]]
        [keys.Return] = function(self) 
            
            if sources[model.fp_1D_index] ~= nil then	
            --if adapters[model.fp_1D_index] ~= nil then
                view.timer:stop()
                model:set_active_component(
                                Components.SLIDE_SHOW)

                model:get_controller(Components.SLIDE_SHOW):Prep_Slideshow(
					model.fp_slots[model.fp_index[1]][model.fp_index[2]].extra.index)
                self:get_model():notify()
            end
			play_sound_wrapper("audio/Fo'os Panel to Slideshow.mp3")
            reset_keys()
        end
    }


    function self:on_key_down(k)
        if MenuKeyTable[k] then
            MenuKeyTable[k](self)
        else
            reset_keys()            
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
        --if the key press is a valid move
        if next_spot[1] > 0 and next_spot[1] <= NUM_ROWS     and
           next_spot[2] > 0 and next_spot[2] <= NUM_VIS_COLS and 
           model.fp_slots[next_spot[1]] ~= nil               and
           model.fp_slots[next_spot[1]][next_spot[2]+
                            model.front_page_index-1] ~= nil then
            selected[1] = next_spot[1]
            selected[2] = next_spot[2]
            self:get_model():notify()

			--view:move_selector(false)

        --if trying to rotate the screen-carousel
        elseif dir == Directions.RIGHT or dir == Directions.LEFT then
            local next_index = model.front_page_index + dir[1]
            local upper_bound = math.ceil(#sources / NUM_ROWS) -
                                     (NUM_VIS_COLS-1)
--            local upper_bound = math.ceil(#adapters / NUM_ROWS) -
--                                     (NUM_VIS_COLS-1)

            --if the rotation is valid
            if next_index > 0 and next_index <= upper_bound and
               model.fp_slots[next_spot[1]] ~= nil          and
               model.fp_slots[next_spot[1]][next_spot[2]+
                           model.front_page_index-1] ~= nil then
                model.front_page_index = next_index
                self:get_model():notify()

				--view:move_selector(true)
            else
                reset_keys()
            end
        else
            reset_keys()
        end

    end
end)
