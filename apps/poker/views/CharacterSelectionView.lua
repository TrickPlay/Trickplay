CharacterSelectionView = Class(View, function(view, model, ...)
    view._base.init(view,model)

    -- text instructing the player to select a character
    
    local choose_char_text = Text{
        text = "Choose Your Dog",
        font = DEFAULT_FONT,
        color = DEFAULT_COLOR,
        opacity = 180
    }
    choose_char_text.anchor_point = {0, choose_char_text.h/2}
    local select_ai_text = Text{
        text = "Choose Your Opponents\n      Then Press Start",
        font = DEFAULT_FONT,
        color = DEFAULT_COLOR,
        opacity = 180
    }
    select_ai_text.anchor_point = {0, select_ai_text.h/2}
    
    choose_char_text.position = {1920/2-choose_char_text.width/2, 1080/2-choose_char_text.height/2 + 50}
    select_ai_text.position = {1920/2-select_ai_text.width/2, 1080/2-select_ai_text.height/2 + 100}
    
    local background = {
        choose_char_text,
        select_ai_text
    }

    -- background/static stuff
    local button_seat_chosen = Image{src="assets/new_buttons/ButtonSeatChosen.png", opacity=0}
    local button_seat_chosen_on = Image{src="assets/new_buttons/ButtonSeatChosen-on.png",opacity=0}

    screen:add(button_seat_chosen, button_seat_chosen_on)

    local seats_chosen = {
        {
            FocusableImage(0,0, Clone{source=button_seat_chosen},
                Clone{source=button_seat_chosen_on}),
            FocusableImage(0,0, Clone{source=button_seat_chosen},
                Clone{source=button_seat_chosen_on}),
            FocusableImage(0,0, Clone{source=button_seat_chosen},
                Clone{source=button_seat_chosen_on}),
            FocusableImage(0,0, Clone{source=button_seat_chosen},
                Clone{source=button_seat_chosen_on}),
        },
        {
            FocusableImage(0,0, Clone{source=button_seat_chosen},
                Clone{source=button_seat_chosen_on}),
            "","","",
            FocusableImage(0,0, Clone{source=button_seat_chosen},
                Clone{source=button_seat_chosen_on}),
        }
    }
    for i,v in ipairs(seats_chosen[1]) do
        v.group.x = MDPL[i+1][1]
        v.group.y = MDPL[i+1][2]
        v.image.x = 10
        v.image.y = 10
        v.group.opacity = 0
    end
    seats_chosen[2][1].group.x = MDPL[1][1]
    seats_chosen[2][1].group.y = MDPL[1][2]
    seats_chosen[2][1].image.x = 10
    seats_chosen[2][1].image.y = 10
    seats_chosen[2][1].group.opacity = 0
    seats_chosen[2][5].group.x = MDPL[6][1]
    seats_chosen[2][5].group.y = MDPL[6][2]
    seats_chosen[2][5].image.x = 10
    seats_chosen[2][5].image.y = 10
    seats_chosen[2][5].group.opacity = 0
    view.seats_chosen = seats_chosen

    --create the components
    local start_button = FocusableImage(MDPL.START[1], MDPL.START[2],
        "start_button", "start_button_on")
    view.start_button = start_button
    start_button.group.opacity = 0
    local exit_button = FocusableImage(MDPL.EXIT_MENU[1], MDPL.EXIT_MENU[2],
        "exit_button", "exit_button_on")
    local help_button = FocusableImage(MDPL.HELP_MENU[1], MDPL.HELP_MENU[2],
        "help_button", "help_button_on")
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

    --background ui
    view.background_ui = Group{name = "start_menu_background_ui", position = {0, 0}}
    view.background_ui:add(unpack(background))

    --all ui junk for this view
    view.ui=Group{name="start_menu_ui", position={0,0}}
    view.ui:add(view.background_ui)
    for i,t in ipairs(seats_chosen) do
        for j,v in ipairs(t) do
            if(v.group) then view.ui:add(v.group) end
        end
    end
    for _,v in ipairs(view.items[1]) do
        if(v.group) then view.ui:add(v.group) else view.ui:add(v) end
    end
    for _,v in ipairs(view.items[2]) do
        if(v.group) then view.ui:add(v.group) else view.ui:add(v) end
    end
--    view.ui:add(unpack(view.text))
--    view.ui:add(button_focus)
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
                select_ai_text:animate{duration=CHANGE_VIEW_TIME+100, opacity=170}
            end
            if(controller.playerCounter >= 2) then start_button.group.opacity = 255 end
            for i,t in ipairs(view.items) do
                for j,item in ipairs(t) do
                    if(i == controller:get_selected_index()) and 
                      (j == controller:get_subselection_index()) then
                        -- set the positions of the focus-highlights correctly
                        --[[
                        button_focus.position = {
                            MDPL[controller:getPosition(i,j)][1]-15,
                            MDPL[controller:getPosition(i,j)][2]-15
                        }
                        --]]
                        -- hide buttons for selecting seats already selected
                        if(model.positions[controller:getPosition(i,j)]) then
                            item.group.opacity = 0
                        end
                        if seats_chosen[i][j].is_a
                          and seats_chosen[i][j]:is_a(FocusableImage) then
                            if item.group.opacity == 0 then
                                seats_chosen[i][j].group.opacity = 255
                            end
                            seats_chosen[i][j]:on_focus_inst()
                        end
                        -- show focuses specific to certain buttons
                        if(type(controller:getPosition(i,j)) == "number") then
                            --button_focus.opacity = 0
                            DOG_GLOW[controller:getPosition(i,j)].opacity = 255
                            DOGS[controller:getPosition(i,j)].opacity = 255
                        else
                            --button_focus.opacity = 255
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
                        if seats_chosen[i][j].is_a
                          and seats_chosen[i][j]:is_a(FocusableImage) then
                            seats_chosen[i][j]:out_focus_inst()
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
