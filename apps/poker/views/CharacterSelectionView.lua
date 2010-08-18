CharacterSelectionView = Class(View, function(view, model, ...)
    view._base.init(view,model)
    --first add the background shiz

    local background = {
    }

    --create the components
    local start_button = FocusableImage(MDPL.START[1], MDPL.START[2], "assets/UI/ButtonStartGreen.png", "assets/UI/ButtonStartRed.png")
    local exit_button = FocusableImage(MDPL.EXIT[1], MDPL.EXIT[2], "assets/UI/ButtonExitGreen.png", "assets/UI/ButtonExitRed.png")
    local help_button = FocusableImage(MDPL.HELP[1], MDPL.HELP[2], "assets/UI/ButtonExitGreen.png", "assets/UI/ButtonExitRed.png")

    view.items = {
        {
            Rectangle{color="FFFFFF", width=100, height=100, position = MDPL[2] },
            Rectangle{color="FFFFFF", width=100, height=100, position = MDPL[3] },
            Rectangle{color="FFFFFF", width=100, height=100, position = MDPL[4] },
            Rectangle{color="FFFFFF", width=100, height=100, position = MDPL[5] },
        },
        {
            Rectangle{color="FFFFFF", width=100, height=100, position = MDPL[1] },
            start_button,
            Text(), -- placeholder, makes logic simpler
            Rectangle{color="FFFFFF", width=100, height=100, position = MDPL[6] },
        },
        {
            Text(), exit_button, help_button, Text()
        }
    }
    
    view.text = {
        Text{font = PLAYER_ACTION_FONT, color = Colors.WHITE,
            x = MDPL.START[1] + 30, y = MDPL.START[2] + 20, text = "Start"},
        Text{font = PLAYER_ACTION_FONT, color = Colors.WHITE,
            x = MDPL.EXIT[1] + 40, y = MDPL.EXIT[2] + 20, text = "Exit"},
        Text{font = PLAYER_ACTION_FONT, color = Colors.WHITE,
            x = MDPL.HELP[1] + 35, y = MDPL.HELP[2] + 20, text = "Help"},
    }
    
    --background ui
    view.background_ui = Group{name = "checkoutBackground_ui", position = {0, 0}}
    view.background_ui:add(unpack(background))

    --ui that actually moves
    view.moving_ui=Group{name="checkoutMoving_ui", position=HIDE_TOP}
--    view.moving_ui:add()
    --all ui junk for this view
    view.ui=Group{name="checkout_ui", position={0,0}}
    view.ui:add(unpack(view.items[1]))
    for _,v in ipairs(view.items[2]) do
        if(v.group) then
            view.ui:add(v.group)
        else
            view.ui:add(v)
        end
    end
    for _,v in ipairs(view.items[3]) do
        view.ui:add(v.group)
    end
    view.ui:add(unpack(view.text))

    screen:add(view.ui)

    function view:initialize()
        self:set_controller(CharacterSelectionController(self))
    end
    
    function view:update()
        local controller = self:get_controller()
        local comp = self.model:get_active_component()
        if comp == Components.CHARACTER_SELECTION then
            self.ui.opacity = 255
            self.ui:raise_to_top()
            print("Showing Character Selection UI")
            for i,t in ipairs(view.items) do
                for j,item in ipairs(t) do
                    if(i == controller:get_selected_index()) and 
                      (j == controller:get_subselection_index()) then
                        if(item.on_focus) then
                            item:on_focus()
                        else
                            item.opacity = 255
                        end
                    else
                        if(item.out_focus) then
                            item:out_focus()
                        else
                            item.opacity = 100
                        end
                    end
                end
            end
        else
            print("Hiding Character Selection UI")
            self.ui:complete_animation()
            self.ui.opacity = 0
        end
    end

end)
