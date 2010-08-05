CustomizeFooterController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.CUSTOMIZE)

    local MenuItems = {
        GO_BACK = 1,
        ADD = 2,
        CHECKOUT = 3
    }
    
    local MenuSize = 0
    for k, v in pairs(MenuItems) do
        MenuSize = MenuSize + 1
    end

    -- the default selected index
    local selected = 1

    local function itemSelection(item, name)
        local textObject = view.ui.children[item]
        textObject.editable = true
        textObject:grab_key_focus()
        function textObject:on_key_focus_out()
            self.on_key_focus_out = nil
            args = {}
            args[name] = self.text
            view:get_model():set_address(args)
        end
    end

    local MenuItemCallbacks = {
        [MenuItems.GO_BACK] = function(self)
            print("Backing up")
                    view.parent:get_controller().selected = 1
                    model.current_item.pizzagroup:hide_all()
                    model:set_active_component(Components.FOOD_SELECTION)
                    model:notify()
        end,
        [MenuItems.ADD] = function(self)
                    view.parent:get_controller().selected = 1
                    model.current_item.pizzagroup:hide_all()
                    if model.current_item_is_in_cart == false then
                       print("adding new item")
                       model.cart[#self:get_model().cart + 1] = view:get_model().current_item
                    else
                        print("Not adding,item is already in cart")
                    end

                    if NETWORKING then
                       Navigator:add_pizza(model.current_item:as_dominos_pizza())
                       local total, price = Navigator:get_total()
                       print("\n\n\n\n\n\n\n\n\n\n" ..
                             "Current Total: $" .. tostring(total) .. "\n" ..
                             "Price of just-added pizza: $" .. tostring(price) .. "\n" ..
                             "\n\n\n\n\n\n\n\n\n")
                       if price then
                          model.current_item.Price = "$" .. tostring(price)
                       end
                    end
                    self:get_model():set_active_component(Components.FOOD_SELECTION)
                    print("size of cart",#self:get_model().cart)
                    print(self:get_model().cart[1].Name)
                    self:get_model():notify()
        end,
        [MenuItems.CHECKOUT] = function(self)
                    model.current_item.pizzagroup:hide_all()
                    model:set_active_component(Components.CHECKOUT)
                    model:notify()
        end
    }

    local MenuKeyTable = {
        [keys.Up]    = function(self) self:move_selector(Directions.UP) end,
        [keys.Down]  = function(self) self:move_selector(Directions.DOWN) end,
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

    function self:move_selector(dir)
        if dir[1] ~= 0 then
            --screen:grab_key_focus()
            local new_selected = selected + dir[1]
            if 1 <= new_selected and new_selected <= MenuSize then
                selected = new_selected
            end
            self:get_model():notify()
        elseif dir == Directions.UP then
            --screen:grab_key_focus()
            view.parent:get_controller().curr_comp = view.parent:get_controller().ChildComponents.TAB_BAR
            self:get_model():notify()
        end
    end

    function self:run_callback()
            local success, error_msg = pcall(MenuItemCallbacks[selected], self)
            if not success then print(error_msg) end
    end
end)
