CharacterSelectionController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.CHARACTER_SELECTION)

    local controller = self
    model = view:get_model()

    local CharacterSelectionGroups = {
        TOP = 1,
        MIDDLE = 2,
        BOTTOM = 3
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
        [CharacterSelectionGroups.MIDDLE] = {
            [SubGroups.LEFT_MIDDLE] = function()
                if(playerCounter > 2) then
                    start_a_game()
                end
            end
        },
        [CharacterSelectionGroups.BOTTOM] = {
            [SubGroups.LEFT_MIDDLE] = function()
                exit()
            end,
            [SubGroups.RIGHT_MIDDLE] = function()
                exit()
            end
        }
    }
    
    local function getPosition()

        local num
        
        if selected == 2 and subselection == 1 then
            num = 1
        elseif selected == 1 then
            num = 1 + subselection
        elseif selected == 2 and subselection == 4 then
            num = 6
        else
            error("error selecting position")
        end
        
        return num
        
    end

    local function setCharacterSeat()

        --instantiate the player
        local pos = getPosition()
        if(model.positions[pos]) then return end
        local isHuman = false
        if(playerCounter == 1) then
            isHuman = true
        end
        
        args = {
            isHuman = isHuman,
            number = playerCounter,
            table_position = pos,
            position = model.default_player_locations[ getPosition() ],
            chipPosition = model.default_bet_locations[ getPosition() ],
        }

        -- insertion point
        local i = 1
        while i <= #model.players do
           if pos < model.players[i].table_position then
              break
           end
           i = i+1
        end
        table.insert(model.players, i, Player(args))
        model.positions[pos] = true
        model.currentPlayer = playerCounter
        
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
            if(CharacterSelectionCallbacks[selected][subselection]) then
                CharacterSelectionCallbacks[selected][subselection]()
            else
                setCharacterSeat()
                if(playerCounter >= 6) then
                    start_a_game()
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

    local function check_for_valid(dir)
        if(CharacterSelectionGroups.MIDDLE == selected) and
          (SubGroups.RIGHT_MIDDLE == subselection) then
            if(0 ~= dir[1]) then subselection = subselection + dir[1]
            elseif(0 ~= dir[2]) then subselection = SubGroups.LEFT_MIDDLE
            end
        elseif(CharacterSelectionGroups.BOTTOM == selected) then
            if(SubGroups.LEFT == subselection) then
                subselection = SubGroups.LEFT_MIDDLE
            elseif(SubGroups.RIGHT == subselection) then
                subselection = SubGroups.RIGHT_MIDDLE
            end
        end
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
        check_for_valid(dir)
        print(SubSize, GroupSize)
        print(subselection, selected)
        self:get_model():notify()
    end

end)
