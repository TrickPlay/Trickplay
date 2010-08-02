ProvidersCarouselController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.PROVIDER_SELECTION)

    selected = 1

    local CarouselKeyTable = {
        [keys.Left]   = function(self) self:move_left()  end,
        [keys.Right]  = function(self) self:move_right() end,
        ---[[ 
        [keys.Return] =
        function(self)
            self:get_model():set_active_component(Components.FOOD_SELECTION)
            self:get_model():notify()
            -- compromise so that there's not a full-on lua panic,
            -- but the error message still displays on screen
            --[[
            local success, error_msg = pcall(MenuItemCallbacks[selected], self)
            if not success then print(error_msg) end
            --]]
        end
        --]]
    }

    function self:on_key_down(k)
        if CarouselKeyTable[k] then
           CarouselKeyTable[k](view)
        end
    end

    function self:get_selected_index()
        return selected
    end		
    function self:move_selector(dir)
        if     dir == Directions.LEFT then view:move_left()
        elseif dir == Directions.RIGHT then view:move_right()
        end
    end
end)
