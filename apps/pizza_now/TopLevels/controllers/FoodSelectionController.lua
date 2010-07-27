FoodSelectionController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.FOOD_SELECTION)

    local FoodMenuGroups  = {
        FOOD_HEADER   = 1,
        FOOD_CAROUSEL = 2,
        FOOD_FOOTER   = 3
    }

    local GroupSize = 0
    for k, v in pairs(FoodMenuGroups) do
        GroupSize = GroupSize + 1
    end

    -- the default selected index
    local selected = FoodMenuGroups.FOOD_CAROUSEL

    --initialize the focus to the carousel
    assert(view.items[selected], "view child with index " .. selected .. " is nil!")
    self.child = view.items[selected]:get_controller()

    local FoodMenuCallbacks = {
        [FoodMenuGroups.FOOD_HEADER] = function(self)
            print("delivery options")
            assert(self.child)
            self.child:run_callback()
        end,
        [FoodMenuGroups.FOOD_CAROUSEL] = function(self)
            print("providers")
        end,
        [FoodMenuGroups.FOOD_FOOTER] = function(self)
            print("go back?")
            self.child:run_callback()
        end
    }

    local FoodMenuKeyTable = {
        [keys.Up] = function(self) self:move_selector(Directions.UP) end,
        [keys.Down] = function(self) self:move_selector(Directions.DOWN) end,
        [keys.Left] = function(self) self.child:on_key_down(keys.Left) end,
        [keys.Right] = function(self) self.child:on_key_down(keys.Right) end,
        [keys.Return] = function(self) self.child:on_key_down(keys.Return) end
    }

    function self:on_key_down(k)
        if FoodMenuKeyTable[k] then
            FoodMenuKeyTable[k](self)
        end
    end

    function self:get_selected_index()
        return selected
    end

    function self:move_selector(dir)
        table.foreach(dir, print)
        local new_selected = selected + dir[2]
        if 1 <= new_selected and new_selected <= GroupSize then
            selected = new_selected
        end
        self:get_model():notify()
    end

end)
