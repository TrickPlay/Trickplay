FinalOrderController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.CHECKOUT)

    local model = self.model

    -- the default selected index
    local CartSize = #model.cart
    local Choices = {
       EDIT=1,
       REMOVE=2,
       LAST=2
    }
    self.Choices = Choices
    local selected_choice = Choices.REMOVE
    local selected_item = 1 -- default focus to first item in cart
    local previous_selected = {selected_choice, selected_item}

    local ChoicesCallbacks = {
        [Choices.EDIT] = function(self)
            model:set_active_component(Components.FOOD_SELECTION)
            model:edit_selected_cart_item(selected_item)
            model:notify()
        end,
        [Choices.REMOVE] =
           function(self)
              table.remove(model.cart, selected_item)
              self:get_view():do_remove_animation(selected_item)
              if #model.cart == 0 then
                 self.parent_controller:move_selector(Directions.RIGHT)
                 selected_item = nil
              elseif selected_item > #model.cart then
                 selected_item = #model.cart
              end
           end
    }

    local OptionsInputKeyTable = {
        [keys.Up] = function(self) self:move_selector(Directions.UP) end,
        [keys.Down] = function(self) self:move_selector(Directions.DOWN) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
        [keys.Left] = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Return] =
        function(self)
            -- compromise so that there's not a full-on lua panic,
            -- but the error message still displays on screen
            local success, error_msg = pcall(ChoicesCallbacks[selected_choice], self)
            if not success then print(error_msg) end
        end
    }

    function self:on_key_down(k)
       print("FinalOrderController received keypress: " .. tostring(k))
        if OptionsInputKeyTable[k] then
            OptionsInputKeyTable[k](self)
        end
    end

    function self:get_selected()
        return selected_choice, selected_item
    end

    function self:set_parent_controller(parent_controller)
        self.parent_controller = parent_controller
    end

    function self:on_focus()
       selected_choice, selected_item = unpack(previous_selected)
    end

    function self:out_focus()
       previous_selected = {selected_choice, selected_item}
       selected_choice = nil
       selected_item = nil
    end

    function self:move_selector(dir)
       print("Move selector called in FinalOrderController")
        if(not self.parent_controller) then
            self:set_parent_controller(view.parent_view:get_controller())
        end
        if(0 ~= dir[2]) then
           local new_selected_item = selected_item + dir[2]
           print("current selected_item: " .. tostring(selected_item))
           print("current cart size: " .. tostring(#model.cart))
           if 1 <= new_selected_item and new_selected_item <= #model.cart then
              selected_item = new_selected_item
              print("changed item to " .. tostring(selected_item))
           elseif new_selected_item == #model.cart + 1 then
              --change focus to footer
              self.parent_controller:move_selector(dir)
           end
        elseif 0 ~= dir[1] then
           local new_choice = selected_choice + dir[1]
           print("current choice: " .. tostring(selected_choice))
           if 1 <= new_choice and new_choice <= Choices.LAST then
              selected_choice = new_choice
              print("changed choice to " .. tostring(selected_choice))
           elseif new_choice == Choices.LAST+1 then
              --change focus to credit info
              self.parent_controller:move_selector(dir)
           end
        else
           error("something sucks")
        end
        self:get_model():notify()
    end

    function self:run_callback()
       local success, error_msg = pcall(ChoicesCallbacks[selected_choice], self)
       if not success then print(error_msg) end
    end

    function self:refresh_cart()
       view:refresh_cart()
    end
end)
