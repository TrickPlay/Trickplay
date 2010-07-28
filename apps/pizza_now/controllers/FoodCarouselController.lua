FoodCarouselController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.FOOD_SELECTION)

    selected = 1

    MenuItemCallBacks = {
        function(self) --Build Your Own Pizza
            model.current_item = EmptyPizza()
            self:get_model():set_active_component(Components.CUSTOMIZE)
            self:get_model():get_active_controller():init_shit()
            self:get_model():get_controller(Components.TAB):init_shit()
            self:get_model():notify()
        end,
        function(self) --SpecialtyPizza
            --model.current_item = EmptyPizza()
            self:get_model():set_active_component(Components.ITEM_SELECTION)
            self:get_model():notify()
        end
    }

    local CarouselKeyTable = {
        [keys.Left]   = function(self) self:move_selector(Directions.LEFT)  end,
        [keys.Right]  = function(self) self:move_selector(Directions.RIGHT) end,
       
        [keys.Return] =
        function(self)
            print("Constructing PIZZA")
            self:get_model().current_item = EmptyPizza()
            self:get_model().current_item.Name = "Pizza"
            self:get_model():set_active_component(Components.CUSTOMIZE)
            self:get_model():get_active_controller():init_shit()
            self:get_model():get_controller(Components.TAB):init_shit()
            self:get_model():notify()
        end
    }

    function self:on_key_down(k)
        if CarouselKeyTable[k] then
           CarouselKeyTable[k](self)
        end
    end

    function self:get_selected_index()
        return selected
    end		

    function self:move_selector(dir)

        if     dir == Directions.LEFT  then 
            if selected == 1 then
                selected = #view.menu_items
            else
                selected = selected - 1
            end
            view:move_left()

        elseif dir == Directions.RIGHT then 
            if selected == #view.menu_items then
                selected = 1
            else
                selected = selected + 1
            end
            view:move_right()
        end

    end
end)
