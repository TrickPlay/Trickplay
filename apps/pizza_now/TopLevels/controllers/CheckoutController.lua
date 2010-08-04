CheckoutController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.CHECKOUT)

    model = view:get_model()

    local CheckoutGroups = {
        ORDER = 1,
        DETAILS = 2,
        FOOTER = 3
    }

    local GroupSize = 0
    for k, v in pairs(CheckoutGroups) do
        GroupSize = GroupSize + 1
    end

    -- the default selected index
    local selected = CheckoutGroups.DETAILS

    --initialize the focus to the ORDER group
    assert(view.items[selected]:get_controller(), "view child with index "..selected.."is nil!")
    self.child = view.items[selected]:get_controller()

    local CheckoutCallbacks = {
        [CheckoutGroups.ORDER] = function(self)
            print("your order")
            assert(self.child)
            self.child:run_callback()
        end,
        [CheckoutGroups.DETAILS] = function(self)
            print("your details")
            assert(self.child)
            self.child:run_callback()
        end,
        [CheckoutGroups.FOOTER] = function(self)
            print("your footer")
            assert(self.child)
            self.child:run_callback()
        end
    }

    local CheckoutKeyTable = {
        [keys.Up] = function(self) self.child:on_key_down(keys.Up) end,
        [keys.Down] = function(self) self.child:on_key_down(keys.Down) end,
        [keys.Left] = function(self) self.child:on_key_down(keys.Left) end,
        [keys.Right] = function(self) self.child:on_key_down(keys.Right) end,
        [keys.Return] =
        function(self)
            -- compromise so that there's not a full-on lua panic,
            -- but the error message still displays on screen
            local success, error_msg = pcall(CheckoutCallbacks[selected], self)
            if not success then print(error_msg) end
        end
    }

    function self:on_key_down(k)
        if CheckoutKeyTable[k] then
            CheckoutKeyTable[k](self)
        end
    end

    function self:get_selected_index()
        return selected
    end

    local previousSelection = selected

    function self:move_selector(dir)
        screen:grab_key_focus()
        if(0 ~= dir[1]) then
            local new_selected = selected + dir[1]
            if 2 <= new_selected and new_selected <= GroupSize-1 then
                selected = new_selected
                previousSelection = selected
            end
        elseif(0 ~= dir[2]) then
            if(CheckoutGroups.ORDER == selected) or
              (CheckoutGroups.DETAILS == selected) then
                selected = CheckoutGroups.FOOTER
            else
                selected = previousSelection
            end
        end
        self:get_model():notify()
    end

end)
