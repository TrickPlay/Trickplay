BettingView = Class(View, function(view, model, ...)
    view._base.init(view,model)
    --first add the background shiz

    local background = {
        AssetLoader:getImage( "ButtonsOnTable", { position = MDPL.FOLD } )
    }
     
    --create the components
    local fold_button = FocusableImage(MDPL.FOLD[1], MDPL.FOLD[2], nil, "fold_focused")
    local call_button = FocusableImage(MDPL.CALL[1], MDPL.CALL[2], nil, "call_focused")
    local check_button = FocusableImage(MDPL.CALL[1], MDPL.CALL[2], "check_default", "check_focused")
    local bet_button = FocusableImage(MDPL.BET[1], MDPL.BET[2], nil, "bet_focused")

    local exit_button = FocusableImage(MDPL.EXIT[1], MDPL.EXIT[2], "exit_default", "exit_focused")
    local help_button = FocusableImage(MDPL.HELP[1], MDPL.HELP[2], "help_default", "help_focused")

    check_button.group.opacity = 0

    -- up down arrows
    local arrows = {
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
