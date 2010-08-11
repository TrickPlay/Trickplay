MAIN_MENU_FONT   = "KacstArt 42px"
WHITE            = "FFFFFF"
MainMenuView = Class(View, function(view, model, ...)
    local hidden_y = -60
    local shown_y  = 20
    view._base.init(view, model)

    view.ui=Group{
        name     = "Main_Menu_ui",
        position = {0,hidden_y}
    }
    view.bg = Rectangle{
        x        = -1 * view.ui.x,
        y        = -1 * shown_y,
        width    = 1920,
        height   = 100,
        color    = "000000",
        opacity  = 150
    }
    view.logo = Image{src="assets/logo_fo_os.png",
                scale = {.375,.375},
                position = {10,-40}}
    view.menu_items = {
        Text{position = {600,0},
             font     = MAIN_MENU_FONT,
             color    = WHITE,
             text     = "Add Source"
        },
        Text{position = {1100,0},
             font     = MAIN_MENU_FONT,
             color    = WHITE,
             text     = "Resume"
        },
        Text{position = {1600,0},
             font     = MAIN_MENU_FONT,
             color    = WHITE,
             text     = "Exit"
        }
    }
    view.ui:add(view.bg)
    view.ui:add(view.logo)
    view.ui:add(unpack(view.menu_items))

    screen:add(view.ui)

    function view:initialize()
        self:set_controller(MainMenuController(self))
    end

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Components.MAIN_MENU  then
            print("\n\nShowing MainMenuView UI\n")

            view.ui:raise_to_top()
            view.ui.opacity = 255      
  
            if view.ui.y ~= shown_y then
                view.ui:animate{duration = 2*CHANGE_VIEW_TIME,
                                y        = shown_y
                }
            end

            local sel = controller:get_selected_index()
            print("index is",sel)
            for i = 1,#view.menu_items do
                if sel == i then
                    view.menu_items[i]:animate{
                        duration = CHANGE_VIEW_TIME,
                        opacity  = 255
                    }
                else
                    view.menu_items[i]:animate{
                        duration = CHANGE_VIEW_TIME,
                        opacity  = 100
                    }
                end
            end
        else
            print("Hiding MainMenuView UI")
            view.ui:complete_animation()
            view.ui:animate{duration = 2*CHANGE_VIEW_TIME,
                            y        = hidden_y
            }

            --view.ui.opacity = 0
        end
    end

end)
