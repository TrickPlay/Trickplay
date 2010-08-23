CharacterSelectionView = Class(View, function(view, model, ...)
    view._base.init(view,model)
    --first add the background shiz

    local background = {
        Image{
            position = {MDPL.START[1]+5, MDPL.START[2]+10},
            src = "assets/UI/shadow_beginning.png"
        },
        Image{
            position = {MDPL.START[1], MDPL.START[2]},
            src = "assets/UI/new/start_unclickable.png"
        }
    }

    --create the components
    local start_button = FocusableImage(MDPL.START[1], MDPL.START[2], "assets/UI/new/start_default.png", "assets/UI/new/start_focused.png")
    local exit_button = FocusableImage(MDPL.EXIT_MENU[1], MDPL.EXIT_MENU[2], "assets/UI/new/exit_default.png", "assets/UI/new/exit_focused.png")
    local help_button = FocusableImage(MDPL.HELP_MENU[1], MDPL.HELP_MENU[2], "assets/UI/new/help_default.png", "assets/UI/new/help_focused.png")

    start_button.group.opacity = 0

    view.items = {
        {
            Rectangle{color="FFFFFF", width=100, height=100, position = MDPL[2], opacity = 0},
            Rectangle{color="FFFFFF", width=100, height=100, position = MDPL[3], opacity = 0},
            Rectangle{color="FFFFFF", width=100, height=100, position = MDPL[4], opacity = 0},
            Rectangle{color="FFFFFF", width=100, height=100, position = MDPL[5], opacity = 0},
        },
        {
            Rectangle{color="FFFFFF", width=100, height=100, position = MDPL[1], opacity = 0},
            help_button, start_button, exit_button,
            Rectangle{color="FFFFFF", width=100, height=100, position = MDPL[6], opacity = 0},
        },
    }
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
    view.ui:add(unpack(view.items[1]))
    for _,v in ipairs(view.items[2]) do
        if(v.group) then
            view.ui:add(v.group)
        else
            view.ui:add(v)
        end
    end
--    view.ui:add(unpack(view.text))

    screen:add(view.ui)

    function view:initialize()
        self:set_controller(CharacterSelectionController(self))
    end
    
    function view:update()
        local controller = self:get_controller()
        local comp = self.model:get_active_component()
        if comp == Components.CHARACTER_SELECTION then
            self.ui.opacity = 255
--            self.ui:raise_to_top()
--            print("Showing Character Selection UI")
            for i,t in ipairs(view.items) do
                for j,item in ipairs(t) do
                    if(i == controller:get_selected_index()) and 
                      (j == controller:get_subselection_index()) then
                        if(type(item) == "table" and item:is_a(FocusableImage)) then
                            item:on_focus()
                        else
                            DOG_GLOW[controller:getPosition(i,j)].opacity = 255
                            DOGS[controller:getPosition(i,j)].opacity = 255
                        end
                    else
                        if(type(item) == "table" and item:is_a(FocusableImage)) then
                            item:out_focus()
                        else
                            DOG_GLOW[controller:getPosition(i,j)].opacity = 120
                             
                            DOGS[controller:getPosition(i,j)].opacity = 0
                            
                            for _,player in ipairs(model.players) do
                                player.dog.opacity = 255
                            end
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
