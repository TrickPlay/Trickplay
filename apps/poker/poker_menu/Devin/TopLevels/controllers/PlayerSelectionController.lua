PlayerSelectionController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.PLAYER_SELECTION)

    local controller = self
    model = view:get_model()

    local PlayerGroups = {
        TOP = 1,
        BOTTOM = 2,
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

    local PlayerCallbacks = {
        --[[[PlayerGroups.TOP] = function(self)
        end,
        [PlayerGroups.BOTTOM] = function(self)
        end]]
    }

    local function setPlayerSeat()
        --instantiate the player
        local user = false
        if(playerCounter == 1) then
            user = HUMAN
        end
        args = {
            user = user,
            row = selected,
            col = subselection,
            number = playerCounter,
            position = model.default_player_locations[ (selected-1)*3 + subselection ]
        }
        model.players[playerCounter] = Player(args)
        model.players[playerCounter]:makeChips()
        model.currentPlayer = playerCounter
        --model.players[playerCounter].status = PlayerStatusView(model, nil, model.players[playerCounter]):initialize()
        
        playerCounter = playerCounter + 1
        self:get_model():notify()
    end

    local PlayerSelectionKeyTable = {
        [keys.Up] = function(self) self:move_selector(Directions.UP) end,
        [keys.Down] = function(self) self:move_selector(Directions.DOWN) end,
        [keys.Left] = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
        [keys.Return] =
        function(self)
            setPlayerSeat()
            self:get_model():set_active_component(Components.PLAYER_BETTING)
            self:get_model():notify()
        end
    }

    function self:on_key_down(k)
        if PlayerSelectionKeyTable[k] then
            PlayerSelectionKeyTable[k](self)
        end
    end

    function self:get_selected_index()
        return selected
    end

    function self:get_subselection_index()
        return subselection
    end

    function self:move_selector(dir)
        screen:grab_key_focus()
        if(0 ~= dir[1]) then
            local new_selected = subselection + dir[1]
            if 1 <= new_selected and SubSize >= new_selected then
                subselection = new_selected
            end
        elseif(0 ~= dir[2]) then
            local new_selected = selected + dir[2]
            if 1 <= new_selected and GroupSize >= new_selected then
                selected = new_selected
            end
        end
        self:get_model():notify()
    end

end)
