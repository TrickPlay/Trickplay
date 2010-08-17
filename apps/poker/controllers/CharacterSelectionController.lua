CharacterSelectionController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.CHARACTER_SELECTION)

    local controller = self
    model = view:get_model()

    local CharacterSelectionGroups = {
        TOP = 1,
        MIDDLE = 2,
        BOTTOM = 3,
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
    local selected = CharacterSelectionGroups.MIDDLE
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
            end,
            [SubGroups.RIGHT_MIDDLE] = function()
                print("starting tutorial")
                if not TUTORIAL then
                    TUTORIAL = Popup:new{ group=AssetLoader:getImage("TutorialGameplay",{opacity=0}), animate_in = {opacity=255, duration=500}, on_fade_in = function() end }
                else
                    TUTORIAL.fade = "out"
                    TUTORIAL.on_fade_out = function() screen:remove(TUTORIAL.group) TUTORIAL = nil end
                    TUTORIAL:render()
                end
            end
        },
        [CharacterSelectionGroups.BOTTOM] = {
            [1] = function() exit() end
        }
    }
    
    local function getPosition()
        --[[ Old way of getting position
        local num = (selected-1)*SubSize + subselection
        
        if num == 8 then num = 6 end
    
        return num
        --]]
        
        ---[[ better?
        local num
        
        if selected == 2 and subselection == 1 then
            num = 1
        elseif selected == 1 then
            num = 1 + subselection
        elseif selected == 2 and subselection == 4 then
            num = 6
        end
        
        return num
        --]]
        
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
            row = selected,
            col = subselection,
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
            local success, error_msg = 
                pcall(CharacterSelectionCallbacks[selected][subselection], self)
            if not success then
                print(error_msg)
                if(playerCounter >= 6) then
                    setCharacterSeat()
                    start_a_game()
                elseif(selected == CharacterSelectionGroups.MIDDLE) and
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
            -- You can only move to exit on the bottom row
            if selected == 3 then
                subselection = 1
            end
        elseif(0 ~= dir[2]) then
            local new_selected = selected + dir[2]
            if 1 <= new_selected and GroupSize >= new_selected then
                -- If you move off the bottom, go to #2
                if selected == 3 then
                    subselection = 2
                end
                selected = new_selected
            end
            if selected == 3 then
                subselection = 1
            end
        end
        print(SubSize, GroupSize)
        print(subselection, selected)
        self:get_model():notify()
    end

end)
