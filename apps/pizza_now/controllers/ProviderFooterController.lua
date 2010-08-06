ProviderFooterController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.PROVIDER_SELECTION)

    local controller = self
    local model = view:get_model()

    local MenuItems = {
        GO_BACK = 1,
        STREET = 2,
        APT = 3,
        CITY = 4,
        ZIP = 5
    }
    
    local MenuSize = 0
    for k, v in pairs(MenuItems) do
        MenuSize = MenuSize + 1
    end

    -- the default selected index
    local selected = 2
    local previous_selected = 2

    local function itemSelection(item, name)
        local textObject = view.items[item]
        local defaultText = textObject.text
        textObject.editable = true
        textObject:grab_key_focus()
        textObject.text = ""
        function textObject:on_key_down(k)
            if(keys.Left == k or keys.Right == k) then
                self.on_key_down = nil
                screen:grab_key_focus()
                controller:on_key_down(k)
                return true
            end
        end
        function textObject:on_key_focus_out()
            self.editable = false
            self.on_key_focus_out = nil
            if(self.text == "") then
                self.text = defaultText
            else
                args = {}
                args[name] = self.text
                view:get_model():set_address(args)
            end
        end
    end

    local MenuItemCallbacks = {
        [MenuItems.GO_BACK] = function(self)
            print("Backing up")
            view.exitItem.group:animate{duration = 200, opacity = 0}
            view.exitButtonPress:animate{
                duration = 200, opacity = 255,
                on_completed = function ()
                    view.exitItem.group:animate{duration = 100, opacity = 255}
                    view.exitButtonPress:animate{duration = 100, opacity = 0}
                    exit()
                end
            }
        end,
        [MenuItems.STREET] = function(self)
            itemSelection(MenuItems.STREET, "street")
        end,
        [MenuItems.APT] = function(self)
            itemSelection(MenuItems.APT, "apartment")
        end,
        [MenuItems.CITY] = function(self)
            itemSelection(MenuItems.CITY, "city")
        end,
        [MenuItems.ZIP] = function(self)
            itemSelection(MenuItems.ZIP, "zip")
        end
    }

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

    function self:on_focus()
        selected = previous_selected
    end

    function self:out_focus()
        previous_selected = selected
        selected = 0
    end

    function self:move_selector(dir)
        screen:grab_key_focus()
        local new_selected = selected + dir[1]
        if 1 <= new_selected and new_selected <= MenuSize then
            selected = new_selected
        end
        self:get_model():notify()
        if(selected ~= MenuItems.GO_BACK) then
            self:run_callback()
        end
    end

    function self:run_callback()
            local success, error_msg = pcall(MenuItemCallbacks[selected], self)
            if not success then print(error_msg) end
    end
end)
