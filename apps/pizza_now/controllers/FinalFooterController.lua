FinalFooterController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.CHECKOUT)

    local MenuItems = {
        GO_BACK = 1,
        PLACE_ORDER = 2
    }
    
    local MenuSize = 0
    for k, v in pairs(MenuItems) do
        MenuSize = MenuSize + 1
    end

    -- the default selected index
    local selected = 0
    local previous_selected = 1

    local MenuItemCallbacks = {
        [MenuItems.GO_BACK] = function(self)
            print("back dat shit up")
            view.items[1][2]:animate{duration = 200, opacity = 0}
            view.pressed_button:animate{
                duration = 200, opacity = 255,
                on_completed = function()
                    view.items[1][2]:animate{duration = 100, opacity = 255}
                    view.pressed_button:animate{duration = 100, opacity = 0}
                    self:get_model():set_active_component(Components.FOOD_SELECTION)
                    self:get_model():notify()
                end
            }
        end,
        [MenuItems.PLACE_ORDER] = function(self)
        end,
    }

    local MenuKeyTable = {
        [keys.Up]    = function(self) self:move_selector(Directions.UP) end,
        [keys.Left]  = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right]  = function(self) self:move_selector(Directions.RIGHT) end,
        [keys.Return] = function(self)
            -- compromise so that there's not a full-on lua panic,
            -- but the error message still displays on screen
            local success, error_msg = pcall(MenuItemCallbacks[selected], self)
            if not success then print(error_msg) end
        end
    }

    function self:on_key_down(k)
        if MenuKeyTable[k] then
            MenuKeyTable[k](self)
        end
    end

    function self:get_selected_index()
        return selected
    end

    function self:set_parent_controller(parent_controller)
        print("\n\n\nhere\n\n\n")
        self.parent_controller = parent_controller
    end

    function self:on_focus()
        selected = previous_selected
    end

    function self:out_focus()
        previous_selected  = selected
        selected = 0
    end

    function self:move_selector(dir)
        if(not self.parent_controller) then
            self:set_parent_controller(view.parent_view:get_controller())
        end
        if(0 ~= dir[2]) then
            self.parent_controller:move_selector(dir)
        elseif(0 ~= dir[1]) then
            local new_selected = selected + dir[1]
            if(1 <= new_selected and new_selected <= MenuSize) then
                selected = new_selected
            end
        else
            error("someth'n eff'd up")
        end
        self:get_model():notify()
    end

    function self:run_callback()
            local success, error_msg = pcall(MenuItemCallbacks[selected], self)
            if not success then print(error_msg) end
    end
end)
