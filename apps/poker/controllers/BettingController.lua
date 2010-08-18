BettingController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.PLAYER_BETTING)

    local controller = self
    model = view:get_model()

    local PlayerGroups = {
        TOP = 1,
    }
    local SubGroups = {
        FOLD = 1,
        CALL = 2,
        RAISE = 3
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
    local subselection = SubGroups.CALL
    --the number of the current player selecting a seat
    local playerCounter = 1

    local betCallback = function() end
    local updated = false -- updated is true when the player bet has
                          --been initialized to the proper
                          --bet. shouldn't just have the same bet as
                          --before.

    local PlayerCallbacks = {
        [SubGroups.FOLD] = function(self)
        --[[
            local current_bet = model.currentPlayer.bet
            model.currentPlayer.bet = 0
            model.currentPlayer.money = model.currentPlayer.money - current_bet
        --]]
        end,
        [SubGroups.CALL] = function(self)
                                
        end,
        [SubGroups.RAISE] = function(self)
           local bet = model.currentPlayer.bet
           betCallback(bet)
           betCallback = function() end
           updated = false
           self:get_model():set_active_component(Components.GAME)
           self:get_model():notify()
        end
    }

    local PlayerSelectionKeyTable = {
        [keys.Up] = function(self) self:move_selector(Directions.UP) end,
        [keys.Down] = function(self) self:move_selector(Directions.DOWN) end,
        [keys.Left] = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
        [keys.Return] =
        function(self)
           local bet = model.currentPlayer.bet
           -- weird logic to make it see a fold
           local fold = subselection == SubGroups.FOLD
           print("fold?", fold)
           betCallback(fold, bet)
           betCallback = function() end
           updated = false
           self:get_model():set_active_component(Components.GAME)
           self:get_model():notify()
           -- local success, error_msg = pcall(PlayerCallbacks[subselection], self)
           -- if not success then print(error_msg) end
        end,
    }

    function self:set_callback(cb)
       print("callback set")
       betCallback = cb
    end

    function self:on_key_down(k)
       print("bettingcontroller on_key_down")
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
        local orig_bet = model.orig_bet
        local call_bet = model.call_bet
        local min_raise = model.min_raise
        local player = model.currentPlayer
        -- Change button
        if(0 ~= dir[1]) then
            local new_selected = subselection + dir[1]
            if player.bet+player.money <= call_bet then
               SubSize = SubGroups.CALL -- 2
               raise_enabled = false
            else
               SubSize = SubGroups.RAISE -- 3
               raise_enabled = true
            end

            if 1 <= new_selected and SubSize >= new_selected then
               subselection = new_selected
               if subselection == SubGroups.FOLD then
                  player.bet, player.money = orig_bet, player.money+player.bet-orig_bet
               elseif subselection == SubGroups.CALL then
                  if call_bet <= player.bet+player.money then -- TODO gogogo.
                     player.bet, player.money = call_bet, player.money+player.bet-call_bet
                  else
                     player.bet, player.money = player.bet+player.money, 0
                  end
               elseif subselection == SubGroups.RAISE then
                  local bet = call_bet + min_raise
                  if call_bet < player.bet + player.money and player.bet + player.money < bet then
                     bet = player.bet+player.money
                  end
                  player.bet, player.money = bet, player.bet+player.money-bet
               end
            end
        -- Change bet
        elseif(0 ~= dir[2]) and subselection == SubGroups.RAISE then
            local new_money = model.currentPlayer.money + ( dir[2] * model.bet.BIG_BLIND )
            local new_bet = model.currentPlayer.bet + ( - dir[2] * model.bet.BIG_BLIND )
            if new_bet > 0 and new_money >= 0 then
                model.currentPlayer.bet = new_bet
                model.currentPlayer.money = new_money
                print("Current bet:", model.currentPlayer.bet, "Current money:", model.currentPlayer.money)
            end
        end
        self:get_model():notify()
    end

    function self:update()
       if not updated and model:get_active_component() == Components.PLAYER_BETTING then
          subselection = SubGroups.CALL
          updated = true
          local call_bet = model.call_bet
          local player = model.currentPlayer
          if call_bet <= player.bet+player.money then -- TODO gogogo.
             player.bet, player.money = call_bet, player.money+player.bet-call_bet
          else
             player.bet, player.money = player.bet+player.money, 0
          end
       end
       view:update()
    end
end)
