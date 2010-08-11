MAIN_MENU_FONT   = "KacstArt 42px"
WHITE            = "FFFFFF"
HelpMenuView = Class(View, function(view, model, ...)
    local hidden_y = -60
    local shown_y  = 20
    view._base.init(view, model)

    view.ui=Group{
        name     = "Help_Menu_ui",
        position = {500,500}
    }
    view.bg = Rectangle{
        width    = 500,
        height   = 500,
        color    = "000000",
        opacity  = 150
    }
    view.helptext = Text{ position = {10,10},
             font     = MAIN_MENU_FONT,
             color    = WHITE,
         text="I am here to help you, press enter to go back"
    }
    view.ui:add(view.bg)
    view.ui:add(view.helptext)

    screen:add(view.ui)

    function view:initialize()
        self:set_controller(HelpMenuController(self))
    end

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Components.HELP_MENU  then
            print("\n\nShowing MainMenuView UI\n")

            view.ui:raise_to_top()
    
  
            if view.ui.y ~= shown_y then
                view.ui:animate{duration = 2*CHANGE_VIEW_TIME,
                            opacity  = 255
                }
            end
        else
            print("Hiding HelpMenuView UI")
            view.ui:complete_animation()
            view.ui:animate{duration = 2*CHANGE_VIEW_TIME,
                            opacity  = 0
            }

            --view.ui.opacity = 0
        end
    end

end)
