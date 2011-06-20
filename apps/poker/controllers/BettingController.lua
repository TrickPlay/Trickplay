BettingController = Class(Controller,
function(self, router, ...)
    router:attach(self, Components.PLAYER_BETTING)
    self._base.init(self, router, Components.PLAYER_BETTING)
    
    local view = assetman:create_group({name = "betting_ui"})
    screen:add(view)

---------------- Help vars -----------------------------

    local current_selector

    local minRaiseBet = 4
    local current_player
    local orig_bet
    local orig_money
    local call_bet
    local min_raise
    local max_bet
    local in_players
    local bb_p
    local bb_qty

    local bet_callback = function() end
    local updated = false -- updated is true when the player bet has
                          --been initialized to the proper
                          --bet. shouldn't just have the same bet as
                          --before.

    local bet_text = assetman:create_text{
        font = PLAYER_ACTION_FONT,
        color = Colors.YELLOW,
        x = BETTING_BUTTON_POSITIONS.BET[1] + 130,
        y = BETTING_BUTTON_POSITIONS.BET[2] + 45,
        text = "$"
    }

---------------- The Model for the UI -----------------

    local help_selector = {
        object = ButtonView("help_button", BETTING_BUTTON_POSITIONS.HELP[1],
            BETTING_BUTTON_POSITIONS.HELP[2])
    }
    local exit_selector = {
        object = ButtonView("exit_button", BETTING_BUTTON_POSITIONS.EXIT[1],
            BETTING_BUTTON_POSITIONS.EXIT[2])
    }
    local new_deal_selector = {
        object = ButtonView("new_game_button", BETTING_BUTTON_POSITIONS.NEW_DEAL[1],
            BETTING_BUTTON_POSITIONS.NEW_DEAL[2])
    }
    local fold_selector = {
        object = ButtonView("fold_button", BETTING_BUTTON_POSITIONS.FOLD[1],
            BETTING_BUTTON_POSITIONS.FOLD[2])
    }
    local call_selector = {
        object = ButtonView("call_button", BETTING_BUTTON_POSITIONS.CALL[1],
            BETTING_BUTTON_POSITIONS.CALL[2])
    }
    local bet_selector = {
        object = ButtonView("bet_button", BETTING_BUTTON_POSITIONS.BET[1],
            BETTING_BUTTON_POSITIONS.BET[2])
    }
    local selectors = {
        help_selector, exit_selector, new_deal_selector,
        fold_selector, call_selector, bet_selector
    }
    assetman:load_image("assets/new_buttons/ButtonBet+.png", "+button")
    assetman:load_image("assets/new_buttons/ButtonBet-.png", "-button")
    local up_button_clone = assetman:get_clone("+button", {
        x = BETTING_BUTTON_POSITIONS.UP[1]-BETTING_BUTTON_POSITIONS.BET[1],
        y = BETTING_BUTTON_POSITIONS.UP[2]-BETTING_BUTTON_POSITIONS.BET[2],
        opacity = 0
    })
    local down_button_clone = assetman:get_clone("-button", {
        x = BETTING_BUTTON_POSITIONS.DOWN[1]-BETTING_BUTTON_POSITIONS.BET[1],
        y = BETTING_BUTTON_POSITIONS.DOWN[2]-BETTING_BUTTON_POSITIONS.BET[2],
        opacity = 0
    })
    bet_selector.object:add(up_button_clone)
    bet_selector.object:add(down_button_clone)

    help_selector[Directions.LEFT] = new_deal_selector
    help_selector[Directions.RIGHT] = exit_selector
    help_selector[Directions.UP] = call_selector
    help_selector.press = function()
        router:set_active_component(Components.TUTORIAL)
        router:notify()
    end

    new_deal_selector[Directions.RIGHT] = help_selector
    new_deal_selector[Directions.UP] = fold_selector
    new_deal_selector.press = function() game:reset() end

    exit_selector[Directions.LEFT] = help_selector
    exit_selector[Directions.UP] = function()
        if not assetman:has_text_of_name("exit_to_help_text") then
            local text = assetman:create_text{
                text = "Can only move to Help from Exit!",
                name = "exit_to_help_text",
                font = "Sans 36px",
                color = "FFFFFF",
                position = {screen.w/2, 400},
                opacity = 0
            }
            text.anchor_point = {text.w/2, text.h/2}
            screen:add(text)
            Popup:new{group = text, time = 1000}
        end
        mediaplayer:play_sound(BONK_MP3)
    end
    exit_selector.press = function() exit() end

    local function change_bet(dir)
        local new_money = current_player.money + dir[2]
        local new_bet = current_player.bet - dir[2]
        if new_money < 0 then
            new_bet, new_money = new_bet + new_money, 0
        elseif new_bet > max_bet then
            new_bet, new_money = max_bet, new_bet + new_money - max_bet
            self:show_all_in_notification()
        elseif new_bet < minRaiseBet then
            new_bet, new_money = minRaiseBet, new_bet + new_money - minRaiseBet
        end
        if new_bet >= minRaiseBet and new_money >= 0 then
            current_player.bet = new_bet
            current_player.money = new_money
            print("Current bet:", current_player.bet, "Current money:",
                  current_player.money)
            mediaplayer:play_sound(CHANGE_BET_MP3)
        end
        bet_text.text = "$"..current_player.bet
        current_player.bet_chips:set(current_player.bet)
        current_player.status:update_text()
    end

    bet_selector[Directions.LEFT] = call_selector
    bet_selector[Directions.UP] = function()
        up_button_clone.opacity = 255
        up_button_clone:animate{duration = CHANGE_VIEW_TIME, opacity = 0}
        change_bet(Directions.UP)
    end
    bet_selector[Directions.DOWN] = function()
        down_button_clone.opacity = 255
        down_button_clone:animate{duration = CHANGE_VIEW_TIME, opacity = 0}
        change_bet(Directions.DOWN)
    end
    
    call_selector[Directions.RIGHT] = function()
        if current_player.bet + current_player.money > call_bet then
            current_selector.object:off_focus()
            current_selector = bet_selector
            current_selector.object:on_focus()
            mediaplayer:play_sound(ARROW_MP3)
            self:handle_bet_change()
        else
            mediaplayer:play_sound(BONK_MP3)
        end
    end
    call_selector[Directions.LEFT] = fold_selector
    call_selector[Directions.DOWN] = help_selector

    fold_selector[Directions.RIGHT] = call_selector
    fold_selector[Directions.DOWN] = new_deal_selector

    for _,selector in ipairs(selectors) do
        for __,dir in pairs(Directions) do
            if not selector[dir] then
                selector[dir] = function()
                    mediaplayer:play_sound(BONK_MP3)
                end
            end
        end
        -- add to view
        view:add(selector.object.view)
    end

    current_selector = call_selector
    view:add(bet_text)

----------------- Some functions ---------------------

    local function call_or_check()
        if call_bet == 0
        or (call_bet <= bb_qty and current_player == bb_player) then
            return "check"
        end
        return "call"
    end

    function self:ready_bet(args)
        current_player = args.current_player or error("no current_player", 2)
        orig_bet = args.orig_bet or error("no orig_bet", 2)
        orig_money = args.orig_money or error("no orig_money", 2)
        call_bet = args.call_bet or error("no call_bet", 2)
        min_raise = args.min_raise or error("no min_raise", 2)
        max_bet = args.max_bet or error("no max_bet", 2)
        in_players = args.in_players or error("no in_players", 2)
        bb_p = args.bb_p or error("no bb_p", 2)
        bb_qty = args.bb_qty or error("no bb_qty", 2)

        for _,selector in pairs(selectors) do
            selector.object:off_focus()
        end

        current_selector = call_selector
        current_selector.object:on_focus()

        current_player.bet = orig_bet
        if call_bet <= current_player.bet + current_player.money then 
            current_player.bet, current_player.money =
                call_bet, current_player.money + current_player.bet - call_bet
        else
            current_player.bet, current_player.money =
                current_player.bet + current_player.money, 0
        end

        call_selector.object:switch_button_type(call_or_check())

        updated = true
        enable_event_listener(KbdEvent())
        print("human betting ready")

        self:update_views()
    end

    local function change_selector(selector)
        current_selector.object:off_focus()
        current_selector = selector
        current_selector.object:on_focus()
        self:handle_bet_change()
    end

    function self:move(dir)
        if current_selector[dir] then
            if type(current_selector[dir]) == "function" then
                current_selector[dir]()
            else
                current_selector.object:off_focus()
                current_selector = current_selector[dir]
                current_selector.object:on_focus()
                mediaplayer:play_sound(ARROW_MP3)
                self:handle_bet_change()
            end
        end
    end

    function self:return_pressed()
        mediaplayer:play_sound(ENTER_MP3)
        if current_selector.press then
            current_selector.press()
            return
        end
        
        disable_event_listeners()

        local bet = current_player.bet
        -- weird logic to make it see a fold
        local fold = (current_selector == fold_selector)
        print("fold?", fold)
        bet_callback(fold, bet)
        bet_callback = function() end
        updated = false
        router:set_active_component(Components.GAME)
        router:notify()
    end

    function self:set_callback(cb)
       print("callback set")
       bet_callback = cb
    end

    function self:reset()
        current_selector = call_selector
        minRaiseBet = 4

        bet_callback = function() end
        updated = false
    end

    function self:handle_bet_change()
        if not updated then error("need to update betting info", 2) end

        if current_selector == fold_selector then
            local old_money = current_player.money
            current_player.bet, current_player.money =
                orig_bet, current_player.money + current_player.bet - orig_bet
            print("fold_selector: player.money was $"
                  ..old_money..", now $"..current_player.money)
        elseif current_selector == call_selector then
            local old_money = current_player.money
            if call_bet <= current_player.bet + current_player.money then
                current_player.bet, current_player.money =
                    call_bet, current_player.money + current_player.bet - call_bet
            else
                current_player.bet, current_player.money =
                    current_player.bet + current_player.money, 0
            end
            print("call_selector: player.money was $"
                  ..old_money..", now $"..current_player.money)
        elseif current_selector == bet_selector then
            local old_money = current_player.money
            local bet = call_bet + min_raise
            if call_bet < current_player.bet + current_player.money
            and current_player.bet + current_player.money < bet then
                bet = current_player.bet + current_player.money
            end
            minRaiseBet = bet
            current_player.bet, current_player.money =
                bet, current_player.bet + current_player.money - bet
            print("bet_selector: player.money was $"
                  ..old_money..", now $"..current_player.money)
        end
        bet_text.text = "$"..current_player.bet
        current_player.bet_chips:set(current_player.bet)
        current_player.status:update_text()
    end

    function self:notify(event)
        self:update_views()
    end

    function self:update_views()
        local comp = router:get_active_component()
        if comp == Components.PLAYER_BETTING then
            view:show()
            view:raise_to_top()

            bet_text.text = "$"..current_player.bet
            current_player.bet_chips:set(current_player.bet)
        else
            view:complete_animation()
            view:hide()
        end
    end

    function self:show_all_in_notification()
        if assetman:has_text_of_name("cant_bet_any_more_text") then
            return
        end
        local text = assetman:create_text{
            text = "You can't bet anymore, you're already"..
                   "pushing everyone all in!",
            name = "cant_bet_any_more_text",
            font = "Sans 36px",
            color = "FFFFFF",
            position = {screen.w/2, 400},
            opacity = 0
        }
        text.anchor_point = {text.w/2, text.h/2}
        screen:add(text)
        Popup:new{group = text, time = 1000}
    end

    -- constants define coordinate space of button presses
    local FOLD_X_1 = 60
    local FOLD_Y_1 = 585
    local FOLD_X_2 = 217
    local FOLD_Y_2 = 650

    local CALL_X_1 = 250
    local CALL_Y_1 = 585
    local CALL_X_2 = 406
    local CALL_Y_2 = 655

    local BET_X_1 = 440
    local BET_Y_1 = 585
    local BET_X_2 = 565
    local BET_Y_2 = 650

    local UP_X_1 = 440
    local UP_Y_1 = 495
    local UP_X_2 = 560
    local UP_Y_2 = 545

    local DOWN_X_1 = 440
    local DOWN_Y_1 = 680
    local DOWN_X_2 = 560
    local DOWN_Y_2 = 735

    local DEAL_X_1 = 238
    local DEAL_Y_1 = 793
    local DEAL_X_2 = 402
    local DEAL_Y_2 = 855

    local HELP_X_1 = 475
    local HELP_Y_1 = 793
    local HELP_X_2 = 599
    local HELP_Y_2 = 855

    local EXIT_X_1 = 40
    local EXIT_Y_1 = 793
    local EXIT_X_2 = 164
    local EXIT_Y_2 = 855
    function self:handle_click(controller, x, y)
        if not current_player.controller
        or controller ~= current_player.controller then 
            return
        end

        y = y/controller.y_ratio
        x = x/controller.x_ratio

        if x > FOLD_X_1 and x < FOLD_X_2 and y > FOLD_Y_1 and y < FOLD_Y_2 then
            change_selector(fold_selector)
            ctrlman:delegate(TouchEvent{
                controller = controller,
                cb = function()
                    self:update_views()
                    self:return_pressed()
                end,
                x = x,
                y = y,
                pos = "fold"
            })
            return
        elseif x > CALL_X_1 and x < CALL_X_2 and y > CALL_Y_1 and y < CALL_Y_2 then
            change_selector(call_selector)
            self:handle_bet_change()
            ctrlman:delegate(TouchEvent{
                controller = controller,
                cb = function()
                    self:update_views()
                    self:return_pressed()
                end,
                x = x,
                y = y,
                pos = "call"
            })
            return
        elseif x > BET_X_1 and x < BET_X_2 and y > BET_Y_1 and y < BET_Y_2 then
            if current_selector == bet_selector then
                -- be awesome
            elseif current_player.bet + current_player.money > call_bet then
                change_selector(bet_selector)
                self:handle_bet_change()
            else
                mediaplayer:play_sound(BONK_MP3)
                return
            end
            ctrlman:delegate(TouchEvent{
                controller = controller,
                cb = function()
                    self:update_views()
                    self:return_pressed()
                end,
                x = x,
                y = y,
                pos = "bet"
            })
            return
        elseif x > UP_X_1 and x < UP_X_2 and y > UP_Y_1 and y < UP_Y_2 then
            if current_selector == bet_selector then
                self:move(Directions.UP)
            elseif current_player.bet + current_player.money > call_bet then
                change_selector(bet_selector)
                self:handle_bet_change()
                self:move(Directions.UP)
            else
                mediaplayer:play_sound(BONK_MP3)
            end
            ctrlman:delegate(TouchEvent{
                controller = controller,
                cb = nil,
                x = x,
                y = y,
                pos = "plus"
            })
            return
        elseif x > DOWN_X_1 and x < DOWN_X_2 and y > DOWN_Y_1 and y < DOWN_Y_2 then
            if current_selector == bet_selector then
                self:move(Directions.DOWN)
            elseif current_player.bet + current_player.money > call_bet then
                change_selector(bet_selector)
                self:handle_bet_change()
                self:move(Directions.DOWN)
            else
                mediaplayer:play_sound(BONK_MP3)
            end
            ctrlman:delegate(TouchEvent{
                controller = controller,
                cb = nil,
                x = x,
                y = y,
                pos = "minus"
            })
            return
        elseif x > DEAL_X_1 and x < DEAL_X_2 and y > DEAL_Y_1 and y < DEAL_Y_2 then
            change_selector(new_deal_selector)
        elseif x > HELP_X_1 and x < HELP_X_2 and y > HELP_Y_1 and y < HELP_Y_2 then
            change_selector(help_selector)
        elseif x > EXIT_X_1 and x < EXIT_X_2 and y > EXIT_Y_1 and y < EXIT_Y_2 then
            change_selector(exit_selector)
        else
            print("nothing selected")
            return
        end
        self:update_views()
        self:return_pressed()
    end

    function self:on_controller_disconnected(controller)
        if controller ~= current_player.controller or current_player.is_human then
            return
        end

        change_selector(fold_selector)
        self:update_views()
        self:return_pressed()
    end

end)
