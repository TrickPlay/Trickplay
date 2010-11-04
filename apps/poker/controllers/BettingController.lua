BettingController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.PLAYER_BETTING)

    local controller = self
    model = view:get_model()

    local PlayerGroups = {
        TOP = 1,
        BOTTOM = 2
    }
    local SubGroups = {
        FOLD = 1,
        CALL = 2,
        RAISE = 3
    }
    local SubGroups2 = {
        NEW_DEAL = 1,
        HELP = 2,
        EXIT = 3
    }

    local GroupSize = 0
    for k, v in pairs(PlayerGroups) do
        GroupSize = GroupSize + 1
    end
    local SubSize = 0
    for k,v in pairs(SubGroups) do
        SubSize = SubSize + 1
    end
    local SubSize2 = 0
    for k,v in pairs(SubGroups2) do
        SubSize2 = SubSize2 + 1
    end

    -- the default selected index
    local selected = PlayerGroups.TOP
    local subselection = SubGroups.CALL
    --the number of the current player selecting a seat
    local minRaiseBet = 4

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
           if(PlayerGroups.BOTTOM == selected and SubGroups2.EXIT == subselection) then
               exit()
               return
           end
           if(PlayerGroups.BOTTOM == selected and SubGroups2.HELP == subselection) then
               model:set_active_component(Components.TUTORIAL)
               self:get_model():notify()
               return
           end
           if(PlayerGroups.BOTTOM == selected
            and SubGroups2.NEW_DEAL == subselection) then
              game:reset()
              return
           end

           local bet = model.currentPlayer.bet
           -- weird logic to make it see a fold
           local fold = (subselection == SubGroups.FOLD and selected == PlayerGroups.TOP)
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
    PlayerSelectionKeyTable[keys.OK] = PlayerSelectionKeyTable[keys.Return]

    function self:set_callback(cb)
       print("callback set")
       betCallback = cb
    end

    function self:reset()
       selected = PlayerGroups.TOP
       subselection = SubGroups.CALL
       minRaiseBet = 4

       betCallback = function() end
       updated = false
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
       local orig_money = model.orig_money
       local orig_bet = model.orig_bet
       local call_bet = model.call_bet
       local min_raise = model.min_raise
       local player = model.currentPlayer
       print("player.money", player.money)
       print("player.bet", player.bet)
       print("orig_money", orig_money)
       assert(player.money + player.bet == orig_money)
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
          if(PlayerGroups.TOP == selected) then
             if 1 <= new_selected and SubSize >= new_selected then
                subselection = new_selected
                if subselection == SubGroups.FOLD then
                   local old_money = player.money
                   player.bet, player.money = orig_bet, player.money+player.bet-orig_bet
                   print("subgroups.fold: player.money was $" .. old_money .. ", now $" .. player.money)
                elseif subselection == SubGroups.CALL then
                   if call_bet <= player.bet+player.money then -- TODO gogogo.
                      local old_money = player.money
                      player.bet, player.money = call_bet, player.money+player.bet-call_bet
                   else
                      player.bet, player.money = player.bet+player.money, 0
                   end
                elseif subselection == SubGroups.RAISE then
                   local bet = call_bet + min_raise
                   if call_bet < player.bet + player.money and player.bet + player.money < bet then
                      bet = player.bet+player.money
                   end
                   minRaiseBet = bet
                   player.bet, player.money = bet, player.bet+player.money-bet
                   mediaplayer:play_sound(CHANGE_BET_MP3)
                end
             end
          elseif(PlayerGroups.BOTTOM == selected) then
             local new_selected = subselection + dir[1]
             if(1 <= new_selected and SubSize2 >= new_selected) then
                 subselection = new_selected
             end
          else
             error("betting controller eff'd up")
          end
       -- Change bet
       elseif(0 ~= dir[2]) then
          if(selected == PlayerGroups.TOP and subselection == SubGroups.RAISE) then
              local new_money = model.currentPlayer.money + dir[2]
              local new_bet = model.currentPlayer.bet - dir[2]
              local max_bet = model.max_bet
              view:change_bet_animation(dir)
              if new_money < 0 then
                 new_bet, new_money = new_bet+new_money, 0
              elseif new_bet > max_bet then
                 new_bet, new_money = max_bet, new_bet + new_money - max_bet
                 view:show_all_in_notification()
              elseif new_bet < minRaiseBet then
                 new_bet, new_money = minRaiseBet, new_bet+new_money-minRaiseBet
              end
              if new_bet >= minRaiseBet and new_money >= 0 then
                 model.currentPlayer.bet = new_bet
                 model.currentPlayer.money = new_money
                 print("Current bet:", model.currentPlayer.bet, "Current money:", model.currentPlayer.money)
                 mediaplayer:play_sound(CHANGE_BET_MP3)
              end
           else
             local new_selected = selected + dir[2]
             if(1 <= new_selected and GroupSize >= new_selected) then
                if (selected == PlayerGroups.BOTTOM
                and subselection == SubGroups2.EXIT) then
                   local text = Text{
                       text = "Can only move to Help from Exit!",
                       font = "Sans 36px",
                       color = "FFFFFF",
                       position = {screen.w/2, 400},
                       opacity = 0
                   }
                   text.anchor_point = {text.w/2, text.h/2}
                   screen:add(text)
                   Popup:new{group = text, time = 1000}
                else
                   selected = new_selected
                end
             end
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
          player.bet = model.orig_bet
          if call_bet <= player.bet+player.money then -- TODO gogogo.
             player.bet, player.money = call_bet, player.money+player.bet-call_bet
          else
             player.bet, player.money = player.bet+player.money, 0
          end
       end
       view:update()
    end
end)
