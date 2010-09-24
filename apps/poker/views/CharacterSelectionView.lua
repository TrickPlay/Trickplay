CharacterSelectionView = Class(View, function(view, model, ...)
    view._base.init(view,model)

    -- text instructing the player to select a character
    
    local choose_char_text = AssetLoader:getImage("ChooseDog",{})
    local select_ai_text = AssetLoader:getImage("ChooseAI",{})
    
    choose_char_text.position = {1920/2-choose_char_text.width/2, 1080/2-choose_char_text.height/2 + 50}
    select_ai_text.position = {1920/2-select_ai_text.width/2, 1080/2-select_ai_text.height/2 + 100}
    
    local background = {
        choose_char_text,
        select_ai_text
    }

    -- background/static stuff
    local button_seat_chosen = Image{position={-1000,-100}, src="assets/new_buttons/ButtonSeatChosen.png"}

    screen:add(button_seat_chosen)

    seats_chosen = {
        Clone{source=button_seat_chosen},
        Clone{source=button_seat_chosen},
        Clone{source=button_seat_chosen},
        Clone{source=button_seat_chosen},
        Clone{source=button_seat_chosen},
        Clone{source=button_seat_chosen}
    }
    for i,v in ipairs(seats_chosen) do
        v.x = MDPL[i][1] + 10
        v.y = MDPL[i][2] + 10
    end

    --create the components
    local start_button = FocusableImage(MDPL.START[1], MDPL.START[2], "assets/new_buttons/ButtonStart.png", "assets/new_buttons/ButtonStart-on.png")
    start_button.group.opacity = 0
    local exit_button = FocusableImage(MDPL.EXIT_MENU[1], MDPL.EXIT_MENU[2],
        "assets/new_buttons/ButtonExit.png", "assets/new_buttons/ButtonExit-on.png")
    local help_button = FocusableImage(MDPL.HELP_MENU[1], MDPL.HELP_MENU[2],
        "assets/new_buttons/ButtonHelp.png", "assets/new_buttons/ButtonHelp-on.png")
    local button_seat = Image{src = "assets/new_buttons/ButtonSeat.png",opacity=0}
    local button_seat_on = Image{src = "assets/new_buttons/ButtonSeat-on.png",opacity=0}
    screen:add(button_seat, button_seat_on)

    view.items = {
        {
            FocusableImage(MDPL[2][1], MDPL[2][2], Clone{source=button_seat},
                Clone{source=button_seat_on}),
            FocusableImage(MDPL[3][1], MDPL[3][2], Clone{source=button_seat},
                Clone{source=button_seat_on}),
            FocusableImage(MDPL[4][1], MDPL[4][2], Clone{source=button_seat},
                Clone{source=button_seat_on}),
            FocusableImage(MDPL[5][1], MDPL[5][2], Clone{source=button_seat},
                Clone{source=button_seat_on}),
        },
        {
            FocusableImage(MDPL[1][1], MDPL[1][2], Clone{source=button_seat},
                Clone{source=button_seat_on}),
            help_button, start_button, exit_button,
            FocusableImage(MDPL[6][1], MDPL[6][2], Clone{source=button_seat},
                Clone{source=button_seat_on})
        }
    }
    the_items = view.items

    -- focuses
    local button_focus = Image{position={MDPL[1][1]-15, MDPL[1][2]-15}, src="assets/DevinUI/ButtonFocusBig.png", opacity=0}
    --local seat_focus = Image{position={MDPL[1][1]-10,MDPL[1][2]-10}, src="assets/DevinUI/ButtonFocusSmall.png"}
   --[[ 
    view.text = {
        Text{font = PLAYER_ACTION_FONT, color = Colors.WHITE,
            x = MDPL.START[1] + 30, y = MDPL.START[2] + 20, text = "Start"},
        Text{font = PLAYER_ACTION_FONT, color = Colors.WHITE,
            x = MDPL.EXIT_MENU[1] + 40, y = MDPL.EXIT_MENU[2] + 20, text = "Exit"},
        Text{font = PLAYER_ACTION_FONT, color = Colors.WHITE,
            x = MDPL.HELP_MENU[1] + 35, y = MDPL.HELP_MENU[2] + 20, text = "Help"},
    }
    --]]
    --background ui
    view.background_ui = Group{name = "start_menu_background_ui", position = {0, 0}}
    view.background_ui:add(unpack(background))

    --all ui junk for this view
    view.ui=Group{name="start_menu_ui", position={0,0}}
    view.ui:add(view.background_ui)
    view.ui:add(unpack(seats_chosen))
    for _,v in ipairs(view.items[1]) do
        if(v.group) then view.ui:add(v.group) else view.ui:add(v) end
    end
    for _,v in ipairs(view.items[2]) do
        if(v.group) then view.ui:add(v.group) else view.ui:add(v) end
    end
--    view.ui:add(unpack(view.text))
    view.ui:add(button_focus)
    view.ui:add(seat_focus)

    screen:add(view.ui)

    function view:initialize()
        self:set_controller(CharacterSelectionController(self))
    end

    function view:reset()
        -- show the instructions text
        background[1].opacity = 255

        -- show all the buttons for the dog-seats
        for i,v in ipairs(view.items) do
            for j,item in ipairs(v) do
                item.opacity = 255
            end
        end
        -- hide the start button
        start_button.opacity = 0
    end
    
    function view:update()
        local controller = self:get_controller()
        local comp = self.model:get_active_component()
        if comp == Components.CHARACTER_SELECTION then
            self.ui.opacity = 255
--            self.ui:raise_to_top()
--            print("Showing Character Selection UI")
            -- displays instruction text
            if(controller.playerCounter == 0) then
                if(not choose_char_text.opacity == 255) then
                    choose_char_text:animate{duration=CHANGE_VIEW_TIME+100, opacity=255}
                end
                select_ai_text.opacity = 0
            else
                choose_char_text:complete_animation()
                choose_char_text.opacity = 0
                select_ai_text:animate{duration=CHANGE_VIEW_TIME+100, opacity=255}
            end
            for i,t in ipairs(view.items) do
                for j,item in ipairs(t) do
                    if(i == controller:get_selected_index()) and 
                      (j == controller:get_subselection_index()) then
                        -- set the positions of the focus-highlights correctly
                        button_focus.position = {
                            MDPL[controller:getPosition(i,j)][1]-15,
                            MDPL[controller:getPosition(i,j)][2]-15
                        }
                        -- hide buttons for selecting seats already selected
                        if(model.positions[controller:getPosition(i,j)]) then
                            item.group.opacity = 0
                        end
                        -- show focuses specific to certain buttons
                        if(type(controller:getPosition(i,j)) == "number") then
                            seat_focus.opacity = 255
                            button_focus.opacity = 0
                            DOG_GLOW[controller:getPosition(i,j)].opacity = 255
                            DOGS[controller:getPosition(i,j)].opacity = 255
                        else
                            seat_focus.opacity = 0
                            button_focus.opacity = 255
                        end
                        if item.is_a and item:is_a(FocusableImage) then
                            item:on_focus_inst()
                        end
                    else
                        if(type(controller:getPosition(i,j)) == "number") then
                            DOG_GLOW[controller:getPosition(i,j)].opacity = 120
                            DOGS[controller:getPosition(i,j)].opacity = 0
                        end
                            
                        for _,player in ipairs(model.players) do
                            player.dog.opacity = 255
                        end
                        if item.is_a and item:is_a(FocusableImage) then
                            item:out_focus_inst()
                        end
                    end
                end
            end
        else
--            print("Hiding Character Selection UI")
            self.ui:complete_animation()
            self.ui.opacity = 0
        end
    end

end)
