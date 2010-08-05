FoodFooterController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.FOOD_SELECTION)

    local selected = 1
    local MenuItemCallbacks = {}
    function self:refresh()
        MenuSize = #view.items
        MenuItemCallbacks[1] = function(self)
            print("Backing up")

            -- hack to get rid of the provider image at the top of this menu
            local provider_img = screen:find_child("provider_img_clone")
            if provider_img then
               provider_img:unparent()
            end
            self:get_model():set_active_component(Components.PROVIDER_SELECTION)
            self:get_model():notify()
        end
        for i =  2,MenuSize-1 do 
            MenuItemCallbacks[i] = function(self)
                print("editing cart item",MenuSize-i)
                self:get_model().current_item = self:get_model().cart[MenuSize-i]
                self:get_model().current_item_is_in_cart = true
                self:get_model():set_active_component(Components.CUSTOMIZE)
                self:get_model():get_active_controller():init_shit()
                self:get_model():get_controller(Components.TAB):init_shit()
                self:get_model():notify()

            end
        end
        MenuItemCallbacks[MenuSize] = function(self)
            print("Checking OUT")
            self:get_model():set_active_component(Components.CHECKOUT)
            --self:get_model():get_active_controller().view:refresh_cart()
            self:get_model():notify()
        end

    end
    self:refresh()
--[[ 

    -- the default selected index
    local selected = 1

    local MenuItemCallbacks = {
        [MenuItems.GO_BACK] = function(self)
            print("Backing up")
            self:get_model():set_active_component(Components.PROVIDER_SELECTION)
            self:get_model():notify()
        end,
        [MenuItems.CART] = function(self)
            print("Carting")
            --self:get_model():set_active_component(Components.ADDRESS_INPUT)
            --self:get_model():notify()
        end,
        [MenuItems.CONTINUE] = function(self)
            print("Checking OUT")
            self:get_model():set_active_component(Components.CHECKOUT)
            self:get_model():notify()
        end
    }
--]]

    local MenuKeyTable = {
        --[keys.Up]    = function(self) self:move_selector(Directions.UP) end,
        --[keys.Down]  = function(self) self:move_selector(Directions.DOWN) end,
        [keys.Left]  = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
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
    function self:reset_index()
        selected = 1
    end

    function self:move_selector(dir)
        local new_selected = selected + dir[1]
        if 1 <= new_selected and new_selected <= MenuSize then
            selected = new_selected
        end
        self:get_model():notify()
    end

    function self:run_callback()
            local success, error_msg = pcall(MenuItemCallbacks[selected], self)
            if not success then print(error_msg) end
    end
end)
