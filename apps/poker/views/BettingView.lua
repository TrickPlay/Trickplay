BettingView = Class(View, function(view, model, ...)
    view._base.init(view,model)
    --first add the background shiz
    local background = {
    }
     
    --create the components
    local fold_button = FocusableImage(MDPL.FOLD[1], MDPL.FOLD[2],
        "fold_button", "fold_button_on")
    fold_button.extra.text = "FOLD"
    call_button = FocusableImage(MDPL.CALL[1], MDPL.CALL[2],
        "call_button", "call_button_on")
    call_button.extra.text = "CALL"
    check_button = FocusableImage(MDPL.CALL[1], MDPL.CALL[2],
        "check_button", "check_button_on")
    check_button.extra.text = "CALL"
    bet_button = FocusableImage(MDPL.BET[1], MDPL.BET[2],
        "bet_button", "bet_button_on")
    bet_button.extra.text = "BET"

    local new_deal_button = FocusableImage(MDPL.NEW_DEAL[1], MDPL.NEW_DEAL[2],
        "new_deal_button", "new_deal_button_on")
    local exit_button = FocusableImage(MDPL.EXIT[1], MDPL.EXIT[2],
        "exit_button", "exit_button_on")
    exit_button.extra.text = "EXIT"
    local help_button = FocusableImage(MDPL.HELP[1], MDPL.HELP[2],
        "help_button", "help_button_on")
    help_button.extra.text = "HELP"


    check_button.opacity = 0

    -- up down arrows
    arrows = {
        AssetLoader:getImage( "BetArrowUp", { position = MDPL.UP, opacity = 0 } ),
        AssetLoader:getImage( "BetArrowDown", { position = MDPL.DOWN, opacity = 0 } )
    }

---[[
    view.items = {
        {
            fold_button, call_button, bet_button
        },
        {
            new_deal_button, help_button, exit_button
        }
    }
    --]]
    -- create text for the components
    local bet_text = Text{font = PLAYER_ACTION_FONT, color = Colors.YELLOW,
            x = MDPL.BET[1] + 130, y = MDPL.BET[2] + 45, text = "$"}
    
    --background ui
    view.background_ui = Group{name = "bettingBackground_ui", position = {0, 0}}
    view.background_ui:add(unpack(background))

    --all ui junk for this view
    view.ui=Group{name="betting_ui", position={0,0}}
    view.ui:add(view.background_ui)
    for _,v in ipairs(view.items[1]) do
        if v.group then view.ui:add(v.group) else view.ui:add(v) end
    end
    for _,v in ipairs(view.items[2]) do
        if v.group then view.ui:add(v.group) else view.ui:add(v) end
    end
    view.ui:add(check_button.group)
    view.ui:add(bet_text)
    view.ui:add(unpack(arrows))

    view.ui:add(button_focus)
    view.ui:add(bet_focus)

    screen:add(view.ui)

    function view:initialize()
        self:set_controller(BettingController(self))
    end

    function view:change_bet_animation(dir)
        assert(0 ~= dir[2])
        if(1 ~= dir[2]) then
            arrows[1].opacity = 255
            arrows[1]:animate{duration=CHANGE_VIEW_TIME, opacity=0}
        elseif(-1 ~= dir[2]) then
            arrows[2].opacity = 255
            arrows[2]:animate{duration=CHANGE_VIEW_TIME, opacity=0}
        else
            error("wtf mate?")
        end
    end
  
    --@return true for call, false for check
    local function call_or_check()
        local players = model.players
        local player = model.currentPlayer
        local bb_p = model.bb_p
        local bb_qty = model.bb_qty
        local bb_player = players[bb_p]
        if model.call_bet == 0 or
            (model.call_bet <= bb_qty and player == bb_player) then
            check_button.group.opacity = 255
            call_button.group.opacity = 0
            view.items[1][2] = check_button
        else
            check_button.group.opacity = 0
            call_button.group.opacity = 255
            view.items[1][2] = call_button
        end
    end
    
    function view:update()
        local controller = self:get_controller()
        local comp = self.model:get_active_component()
        if comp == Components.PLAYER_BETTING then
            ctrlman:start_accepting_ctrls()

            self.ui.opacity = 255
            self.ui:raise_to_top()
--            print("Showing Betting UI")
            -- figures out whether "call" or "check" should be displayed
            call_or_check()
            for i,t in ipairs(view.items) do
                for j,item in ipairs(t) do
                    if(i == controller:get_selected_index()) and 
                      (j == controller:get_subselection_index()) then
                        -- set the positions of the focus-highlights correctly
                        item:on_focus_inst()
                       --[[ 
                        button_focus.position={
                            MDPL[item.extra.text][1]-13,
                            MDPL[item.extra.text][2]-11
                        }
                        -- show only required focus
                        if(item.extra.text == "BET") then
                            bet_focus.opacity = 255
                            button_focus.opacity = 0
                        else
                            button_focus.opacity = 255
                            bet_focus.opacity = 0
                        end
                        --]]
                    else
                        item:out_focus_inst()
                    end
                end
            end
            
            local player = model.currentPlayer
            bet_text.text = "$"..player.bet

            local playerBet = player.betChips
            
            -- Add chips to the bet
            playerBet:set(player.bet)

        else
--            print("Hiding Betting UI")
            self.ui:complete_animation()
            self.ui.opacity = 0
        end
    end

    local popup_ok = true
    function view:show_all_in_notification()
        if popup_ok then
            local text = Text{
                text="You can't bet anymore, you're already pushing everyone all in!",
                font="Sans 36px",
                color="FFFFFF",
                position={screen.w/2,400},
                opacity=0
            }
            text.anchor_point = {text.w/2, text.h/2}
            screen:add(text)
            Popup:new{
                group = text,
                time = 1000,
                on_fade_out = function() popup_ok = true end
            }
            popup_ok = false
            return
        end
    end
    
end)
