BettingView = Class(View, function(view, model, ...)
    view._base.init(view,model)
    --first add the background shiz

    local background = {
        Image{
            position = {MDPL.FOLD[1], MDPL.FOLD[2]},
            src = "assets/UI/new/buttons_on_table.png"
        }
    }
     
    --create the components
    local fold_button = FocusableImage(MDPL.FOLD[1], MDPL.FOLD[2], "assets/UI/new/fold_default", "assets/UI/new/fold_focused.png")
    local call_button = FocusableImage(MDPL.CALL[1], MDPL.CALL[2], "assets/UI/new/call_default", "assets/UI/new/call_focused.png")
    local check_button = FocusableImage(MDPL.CALL[1], MDPL.CALL[2], "assets/UI/new/check_default.png", "assets/UI/new/check_focused.png")
    local bet_button = FocusableImage(MDPL.BET[1], MDPL.BET[2], "assets/UI/new/bet_default", "assets/UI/new/bet_focused.png")

    local exit_button = FocusableImage(MDPL.EXIT[1], MDPL.EXIT[2], "assets/UI/new/exit_default.png", "assets/UI/new/exit_focused.png")
    local help_button = FocusableImage(MDPL.HELP[1], MDPL.HELP[2], "assets/UI/new/help_default.png", "assets/UI/new/help_focused.png")

    check_button.group.opacity = 0

    -- up down arrows
    local arrows = {
        Image{
            position  = {MDPL.UP[1], MDPL.UP[2]},
            src = "assets/UI/new/betarrow_up.png",
            opacity = 0
        },
        Image{
            position  = {MDPL.DOWN[1], MDPL.DOWN[2]},
            src = "assets/UI/new/betarrow_down.png",
            opacity = 0
        }
    }

    view.items = {
        {
            fold_button, call_button, bet_button
        },
        {
            help_button, exit_button
        }
    }
    
    -- create text for the components
    --[[
    local fold_text = Text{font = PLAYER_ACTION_FONT, color = Colors.WHITE,
            x = MDPL.FOLD[1] + 17, y = MDPL.FOLD[2] + 30, text = "Fold"}
    local call_text = Text{font = PLAYER_ACTION_FONT, color = Colors.WHITE,
            x = MDPL.CALL[1] + 30, y = MDPL.CALL[2] + 30, text = "Call"}
    --]]
    bet_text = Text{font = PLAYER_ACTION_FONT, color = Colors.WHITE,
            x = MDPL.BET[1] + 130, y = MDPL.BET[2] + 35, text = "$"}
    --[[
    local exit_text = Text{font = PLAYER_ACTION_FONT, color = Colors.WHITE,
            x = MDPL.EXIT[1] + 40, y = MDPL.EXIT[2] + 20, text = "Exit"}
    local help_text = Text{font = PLAYER_ACTION_FONT, color = Colors.WHITE,
            x = MDPL.HELP[1] + 35, y = MDPL.HELP[2] + 20, text = "Help"}

    view.text = {
        fold_text, call_text, bet_text, exit_text, help_text
    }
    --]]
    
    --background ui
    view.background_ui = Group{name = "bettingBackground_ui", position = {0, 0}}
    view.background_ui:add(unpack(background))

    --all ui junk for this view
    view.ui=Group{name="betting_ui", position={0,0}}
    view.ui:add(view.background_ui)
    for _,v in ipairs(view.items[1]) do
        view.ui:add(v.group)
    end
    for _,v in ipairs(view.items[2]) do
        view.ui:add(v.group)
    end
    view.ui:add(check_button.group)
    view.ui:add(bet_text)
    view.ui:add(unpack(arrows))

    screen:add(view.ui)
    fold_button.group:raise_to_top()    --compensates for clipping with check_button

    function view:initialize()
        self:set_controller(BettingController(self))
    end

    function view:change_bet_animation(dir)
        assert(0 ~= dir[2])
        if(1 ~= dir[2]) then
            arrows[1]:complete_animation()
            arrows[1].opacity = 255
            arrows[1]:animate{duration=CHANGE_VIEW_TIME, opacity=0}
        elseif(-1 ~= dir[2]) then
            arrows[2]:complete_animation()
            arrows[2].opacity = 255
            arrows[2]:animate{duration=CHANGE_VIEW_TIME, opacity=0}
        else
            error("wtf mate?")
        end
    end
    
    function view:update()
        local controller = self:get_controller()
        local comp = self.model:get_active_component()
        if comp == Components.PLAYER_BETTING then
            self.ui.opacity = 255
            self.ui:raise_to_top()
--            print("Showing Betting UI")
            for i,t in ipairs(view.items) do
                for j,item in ipairs(t) do
                    if(i == controller:get_selected_index()) and 
                      (j == controller:get_subselection_index()) then
                        if(item == call_button) then
                            check_button:on_focus()
                        end
                        item:on_focus()
                    else
                        if(item == call_button) then
                            check_button:out_focus()
                        end
                        item:out_focus()
                    end
                end
            end
            
            local player = model.currentPlayer
            bet_text.text = "$"..player.bet

            if(model.call_bet == 0) then
                check_button.group.opacity = 255
                call_button.group.opacity = 0
            else
                check_button.group.opacity = 0
                call_button.group.opacity = 255
            end
            
            local playerBet = player.betChips
            
            -- Add chips to the bet
            playerBet:set(player.bet)

        else
--            print("Hiding Betting UI")
            self.ui:complete_animation()
            self.ui.opacity = 0
        end
    end

end)
