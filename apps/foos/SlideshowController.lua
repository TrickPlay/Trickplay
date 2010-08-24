SlideshowController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.SLIDE_SHOW)

    -- the default selected index
    -- local selected = 1	the Slideshow object has its own indexing variable

    local MenuKeyTable = {
        [keys.Up]    = function(self) model.curr_slideshow:toggle_timer() end,
        [keys.Down]  = function(self) model.curr_slideshow:toggle_fullscreen() end,
        [keys.Left]  = function(self) model.curr_slideshow:previous_picture() end,
        [keys.Right] = function(self) model.curr_slideshow:next_picture() end,
        [keys.Return] = function(self) 
            Setup_Album_Covers()
            model.curr_slideshow:stop()
            view.ui:clear()
            model.curr_slideshow = {}
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

    function self:set_selected_index(i)
        selected = i
    end

    function self:get_selected_index()
        return selected
    end




    function self:move_selector(dir)
--[[
        local next_spot = selected+dir[2]
        if next_spot >= 1  then
            if next_spot > #view.Slideshow then
                
            else
                selected = next_spot
            end
        end
--]]
        self:get_model():notify()
    end
end)
