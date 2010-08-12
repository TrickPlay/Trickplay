BettingController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.PLAYER_BETTING)

    local controller = self
    model = view:get_model()

    local PlayerGroups = {
        TOP = 1,
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
    local selected = PlayerGroups.TOP
    local subselection = SubGroups.MIDDLE
    --the number of the current player selecting a seat
    local playerCounter = 1

    local PlayerCallbacks = {
        --[[[PlayerGroups.TOP] = function(self)
        end,
        [PlayerGroups.BOTTOM] = function(self)
        end]]
    }

    local PlayerSelectionKeyTable = {
        [keys.Up] = function(self) self:move_selector(Directions.UP) end,
        [keys.Down] = function(self) self:move_selector(Directions.DOWN) end,
        [keys.Left] = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
        [keys.Return] = function(self)
        
            self:get_model():set_active_component(Components.PLAYER_SELECTION)
            self:get_model():notify()
        
        end,
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
        -- Change button
        if(0 ~= dir[1]) then
            local new_selected = subselection + dir[1]
            if 1 <= new_selected and SubSize >= new_selected then
                subselection = new_selected
            end
        -- Change bet
        elseif(0 ~= dir[2]) and subselection == SubGroups.RIGHT then
            local new_money = model.players[ model.currentPlayer ].money + ( dir[2] * model.bet.BIG_BLIND )
            local new_bet = model.players[ model.currentPlayer ].bet + ( - dir[2] * model.bet.BIG_BLIND )
            if new_bet > 0 and new_money >= 0 then
                model.players[ model.currentPlayer ].bet = new_bet
                model.players[ model.currentPlayer ].money = new_money
                print("Current bet:", model.players[ model.currentPlayer ].bet, "Current money:", model.players[ model.currentPlayer ].money)
            end
        end
        self:get_model():notify()
    end

end)
