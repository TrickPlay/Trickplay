CharacterSelectionController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.CHARACTER_SELECTION)

    local controller = self
    model = view:get_model()

    local CharacterSelectionGroups = {
        TOP = 1,
        BOTTOM = 2
    }
    local SubGroups = {
        LEFT = 1,
        LEFT_MIDDLE = 2,
        RIGHT_MIDDLE = 3,
        RIGHT = 4
    }

    local GroupSize = 0
    for k, v in pairs(CharacterSelectionGroups) do
        GroupSize = GroupSize + 1
    end
    local SubSize = 0
    for k,v in pairs(SubGroups) do
        SubSize = SubSize + 1
    end

    -- the default selected index
    local selected = CharacterSelectionGroups.BOTTOM
    local subselection = SubGroups.LEFT_MIDDLE
    assert(selected)
    assert(subselection)
    --the number of the current player selecting a seat
    local playerCounter = 1

    local CharacterSelectionCallbacks = {
        [CharacterSelectionGroups.TOP] = {},
        [CharacterSelectionGroups.BOTTOM] = {
            [SubGroups.LEFT_MIDDLE] = function()
            end,
            [SubGroups.RIGHT_MIDDLE] = function()
                exit()
            end
        }
    }

    local function setCharacterSeat()
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

    local CharacterSelectionKeyTable = {
        [keys.Up] = function(self) self:move_selector(Directions.UP) end,
        [keys.Down] = function(self) self:move_selector(Directions.DOWN) end,
        [keys.Left] = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
        [keys.Return] =
        function(self)
            local success, error_msg = 
                pcall(CharacterSelectionCallbacks[selected][subselection], self)
            if not success then
                print(error_msg)
                setCharacterSeat()
                if(playerCounter > 6) then
                    self:get_model():set_active_component(Components.PLAYER_BETTING)
                    self:get_model():notify()
                end
            end
        end
    }

    function self:on_key_down(k)
        if CharacterSelectionKeyTable[k] then
            CharacterSelectionKeyTable[k](self)
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
