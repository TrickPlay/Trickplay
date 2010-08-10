PlayerSelectionController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.PLAYER_SELECTION)

    model = view:get_model()

    local PlayerGroups = {
        TOP = 1,
        BOTTOM = 2
    }
    local SubGroups = {
        LEFT = 1,
        MIDDLE = 2,
        RIGHT = 3
    }

    local GroupSize = 0
    for k, v in pairs(PlayerGroups) do
        GroupSize = GroupSize + 1
    end
    local SubSize = 0
    for k,v in pairs(SubGroups) do
        SubSize = SubSize + 1
    end

    -- the default selected index
    local selected = PlayerGroups.BOTTOM
    local subselection = SubGroups.MIDDLE
    --the number of the current player selecting a seat
    local playerCounter = 1

    --initialize the focus to the ORDER group
    assert(view.items[selected]:get_controller(), "view child with index "..selected.."is nil!")

    local PlayerCallbacks = {
        [PlayerGroups.TOP] = function(self)
        end,
        [PlayerGroups.BOTTOM] = function(self)
        end
    }

    local PlayerSelectionKeyTable = {
        [keys.Up] = function(self) self.child:on_key_down(keys.Up) end,
        [keys.Down] = function(self) self.child:on_key_down(keys.Down) end,
        [keys.Left] = function(self) self.child:on_key_down(keys.Left) end,
        [keys.Right] = function(self) self.child:on_key_down(keys.Right) end,
        [keys.Return] =
        function(self)
            -- compromise so that there's not a full-on lua panic,
            -- but the error message still displays on screen
            --[[
            local success, error_msg = pcall(PlayerCallbacks[selected], self)
            if not success then print(error_msg) end
            --]]
            setPlayerSeat()
        end
    }

    local function setPlayerSeat()
        --instantiate the player
        local user = false
        if(playerCounter == 1) then
            user = true
        end
        args = {
            user = user,
            row = selected,
            col = subselection
        }
        model.players[playerCounter] = Player(args)
        
        playerCounter = playerCounter + 1
    end

    function self:on_key_down(k)
        if PlayerSelectionKeyTable[k] then
            PlayerSelectionKeyTable[k](self)
        end
    end

    function self:get_selected_index()
        return selected
    end

    function self:move_selector(dir)
        screen:grab_key_focus()
        if(0 ~= dir[1]) then
            local new_selected = selected + dir[1]
            if 1 >= new_selected and SubSize <= new_selected then
                selected = new_selected
            end
        elseif(0 ~= dir[2]) then
            local new_selected = selected + dir[2]
            if 1 >= new_selected and GroupSize <= new_selected then
                selected = new_selected
            end
        end
        self:get_model():notify()
    end

end)
