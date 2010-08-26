BettingView = Class(View, function(view, model, ...)
    view._base.init(view,model)
    --first add the background shiz
    local background = {
    }
     
    --create the components
    local fold_button = Image{position={MDPL.FOLD[1], MDPL.FOLD[2]}, src="assets/DevinUI/fold_6.png"}
    fold_button.text = "FOLD"
    local call_button = Image{position={MDPL.CALL[1], MDPL.CALL[2]}, src="assets/DevinUI/call.png"}
    call_button.text = "CALL"
    local check_button = Image{position={MDPL.CALL[1], MDPL.CALL[2]}, src="assets/DevinUI/check.png"}
    check_button.text = "CALL"
    local bet_button = Image{position={MDPL.BET[1], MDPL.BET[2]}, src="assets/DevinUI/bet.png"}
    bet_button.text = "BET"

    local exit_button = Image{position={MDPL.EXIT[1], MDPL.EXIT[2]}, src="assets/DevinUI/exit.png"}
    exit_button.text = "EXIT"
    local help_button = Image{position={MDPL.HELP[1], MDPL.HELP[2]}, src="assets/DevinUI/help.png"}
    help_button.text = "HELP"

    check_button.opacity = 0

    -- up down arrows
    arrows = {
        AssetLoader:getImage( "BetArrowUp", { position = MDPL.UP, opacity = 0 } ),
        AssetLoader:getImage( "BetArrowDown", { position = MDPL.DOWN, opacity = 0 } )
    }

    view.items = {
        {
            fold_button, call_button, bet_button
        },
        {
            help_button, exit_button
        }
    }

    -- add the focus
    local button_focus = Image{position=MDPL.CALL, src="assets/DevinUI/focus_small.png"}
    local bet_focus = Image{position={MDPL.BET[1]-10,MDPL.BET[2]+5}, src="assets/DevinUI/focus_big.png", opacity=0}
    
    -- create text for the components
    --[[
    local fold_text = Text{font = PLAYER_ACTION_FONT, color = Colors.WHITE,
            x = MDPL.FOLD[1] + 17, y = MDPL.FOLD[2] + 30, text = "Fold"}
    local call_text = Text{font = PLAYER_ACTION_FONT, color = Colors.WHITE,
            x = MDPL.CALL[1] + 30, y = MDPL.CALL[2] + 30, text = "Call"}
    --]]
    local bet_text = Text{font = PLAYER_ACTION_FONT, color = Colors.YELLOW,
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
        view.ui:add(v)
    end
    for _,v in ipairs(view.items[2]) do
        view.ui:add(v)
    end
    view.ui:add(check_button)
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
  
    --@return true for call, false for check
    local function call_or_check()
        local players = model.players
        local player = model.currentPlayer
        local bb_p = model.bb_p
        local bb_qty = model.bb_qty
        local bb_player = players[bb_p]
        if model.call_bet == 0 or
            (model.call_bet <= bb_qty and player == bb_player) then
            check_button.opacity = 255
            call_button.opacity = 0
            view.items[1][2] = check_button
        else
            check_button.opacity = 0
            call_button.opacity = 255
            view.items[1][2] = call_button
        end
    end
    
    function view:update()
        local controller = self:get_controller()
        local comp = self.model:get_active_component()
        if comp == Components.PLAYER_BETTING then
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
                        button_focus.position={
                            MDPL[item.text][1]-13,
                            MDPL[item.text][2]-11
                        }
                        -- show only required focus
                        if(item.text == "BET") then
                            bet_focus.opacity = 255
                            button_focus.opacity = 0
                        else
                            button_focus.opacity = 255
                            bet_focus.opacity = 0
                        end
                    else
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

    function view:show_all_in_notification()
        local text = Text{
            text="You can't bet anymore, you're already pushing everyone all in!",
            font="Sans 36px",
            color="FFFFFF",
            position={screen.w/2,400},
            opacity=0
        }
        text.anchor_point = {text.w/2, text.h/2}
        screen:add(text)
        Popup:new{group = text, time = 1}
       
       --[[
       screen:add(text)
       text:animate{
          duration=200,
          opacity=255,
          on_completed=function(anim, ui)
             if not ui then ui = anim end
             ui:animate{
                duration=200,
                opacity=0,
                on_completed=function(anim,ui)
                   if not ui then ui=anim end
                   ui:unparent()
                end
             }
          end
       }
       --]]
       
    end
    
end)
