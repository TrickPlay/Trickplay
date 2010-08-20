BettingView = Class(View, function(view, model, ...)
    view._base.init(view,model)
    --first add the background shiz

    local background = {
        Image{position = {MDPL.FOLD[1]-35, MDPL.FOLD[2]-20}, src = "assets/UI/ButtonsShadow.png"}
    }
     
    --create the components
    local fold_button = FocusableImage(MDPL.FOLD[1], MDPL.FOLD[2], "assets/UI/ButtonCallGreen.png", "assets/UI/ButtonCallRed.png")
    local call_button = FocusableImage(MDPL.CALL[1], MDPL.CALL[2], "assets/UI/ButtonFoldGreen.png", "assets/UI/ButtonFoldRed.png")
    local bet_button = FocusableImage(MDPL.BET[1], MDPL.BET[2], "assets/UI/ButtonBetGreen.png", "assets/UI/ButtonBetRed.png")

    local exit_button = FocusableImage(MDPL.EXIT[1], MDPL.EXIT[2], "assets/UI/ButtonExitGreen.png", "assets/UI/ButtonExitRed.png")
    local help_button = FocusableImage(MDPL.HELP[1], MDPL.HELP[2], "assets/UI/ButtonExitGreen.png", "assets/UI/ButtonExitRed.png")

    view.items = {
        {
            fold_button, call_button, bet_button
        },
        {
            exit_button, help_button
        }
    }
    
    ---create text for the components
    local fold_text = Text{font = PLAYER_ACTION_FONT, color = Colors.WHITE,
            x = MDPL.FOLD[1] + 17, y = MDPL.FOLD[2] + 30, text = "Fold"}
    local call_text = Text{font = PLAYER_ACTION_FONT, color = Colors.WHITE,
            x = MDPL.CALL[1] + 30, y = MDPL.CALL[2] + 30, text = "Call"}
    local bet_text = Text{font = PLAYER_ACTION_FONT, color = Colors.WHITE,
            x = MDPL.BET[1] + 30, y = MDPL.BET[2] + 30, text = "Bet"}

    local exit_text = Text{font = PLAYER_ACTION_FONT, color = Colors.WHITE,
            x = MDPL.EXIT[1] + 40, y = MDPL.EXIT[2] + 20, text = "Exit"}
    local help_text = Text{font = PLAYER_ACTION_FONT, color = Colors.WHITE,
            x = MDPL.HELP[1] + 35, y = MDPL.HELP[2] + 20, text = "Help"}

    view.text = {
        fold_text, call_text, bet_text, exit_text, help_text
    }
    
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
    view.ui:add(unpack(view.text))

    screen:add(view.ui)

    function view:initialize()
        self:set_controller(BettingController(self))
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
                        item:on_focus()
                    else
                        item:out_focus()
                    end
                end
            end
            
            local player = model.currentPlayer
            bet_text.text = "Bet:     "..player.bet

            if(model.call_bet == 0) then
                call_text.text = "Check"
                call_text.x = MDPL.CALL[1] + 10
            else
                call_text.text = "Call"
                call_text.x = MDPL.CALL[1] + 30
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
