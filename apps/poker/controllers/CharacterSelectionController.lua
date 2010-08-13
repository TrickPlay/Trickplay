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

    local function start_a_game()
        model:set_active_component(Components.GAME)
        game:initialize_game{
            sb=1,
            bb=2,
            endowment=800,
            players=model.players
        }
        old_on_key_down = nil
    end

    local CharacterSelectionCallbacks = {
        [CharacterSelectionGroups.TOP] = {},
        [CharacterSelectionGroups.BOTTOM] = {
            [SubGroups.LEFT_MIDDLE] = function()
                if(playerCounter > 2) then
                    start_a_game()
                end
            end,
            [SubGroups.RIGHT_MIDDLE] = function()
                exit()
            end
        }
    }
    
    local function getPosition()
    
        local num = (selected-1)*SubSize + subselection
        
        if num == 8 then num = 6 end
    
        return num
    end

    local function setCharacterSeat()
        --instantiate the player
        if(model.positions[getPosition()]) then return end
        local isHuman = false
        if(playerCounter == 1) then
            isHuman = true
        end
        
        args = {
            isHuman = isHuman
            row = selected,
            col = subselection,
            number = playerCounter,
            table_position = getPosition(),
            position = model.default_player_locations[ getPosition() ],
            chipPosition = model.default_bet_locations[ getPosition() ],
        }
        model.players[ playerCounter ] = Player(args)
        --model.players[ playerCounter ]:createMoneyChips()
        model.players[ playerCounter ]:createBetChips()
        model.positions[getPosition()] = true
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
                if(playerCounter >= 6) then
                    setCharacterSeat()
                    start_a_game()
                elseif(selected == CharacterSelectionGroups.BOTTOM) and
                      (subselection == SubGroups.LEFT_MIDDLE) then
                    return
                end
                setCharacterSeat()
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
        print(SubSize, GroupSize)
        print(subselection, selected)
        self:get_model():notify()
    end

end)
