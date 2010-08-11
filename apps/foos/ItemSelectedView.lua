MAIN_MENU_FONT   = "KacstArt 36px"
WHITE            = "FFFFFF"
ItemSelectedView = Class(View, function(view, model, ...)
    local hidden_y = -60
    local shown_y  = 20
    view._base.init(view, model)

    view.ui=Group{
        name     = "Main_Menu_ui",
        position = {0,hidden_y}
    }


    view.menu_items = {
        Text{position = {0,0},
             font     = MAIN_MENU_FONT,
             color    = WHITE,
             text     = "SlideShow"
        },
        Text{position = {0,60},
             font     = MAIN_MENU_FONT,
             color    = WHITE,
             text     = "Edit"
        },
        Text{position = {0,120},
             font     = MAIN_MENU_FONT,
             color    = WHITE,
             text     = "Delete"
        },
        Text{position = {0,180},
             font     = MAIN_MENU_FONT,
             color    = WHITE,
             text     = "Go Back"
        }
    }
    view.ui:add(unpack(view.menu_items))

    screen:add(view.ui)

    function view:initialize()
        self:set_controller(ItemSelectedController(self))
    end

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Components.ITEM_SELECTED  then
            print("\n\nShowing ItemSelectedView UI\n")

            view.ui:raise_to_top()
            view.ui.opacity = 255      
            view.ui.position = {model.pic_text[1],model.pic_text[2]}
--[[
            view.ui.y = model.pic_text[1]--(model.selected_picture[1]-1)*screen.width/NUM_COLS
            view.ui.x = model.pic_text[2]--(model.selected_picture[2]-1)*screen.height/NUM_ROWS
            --]]
  
            if view.ui.y ~= shown_y then
                view.ui:animate{duration = CHANGE_VIEW_TIME,
                                opacity  = 255
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
            print("Hiding ItemSelectedView UI")
            view.ui:complete_animation()
            view.ui:animate{duration = CHANGE_VIEW_TIME,
                            opacity  = 0
            }
            controller:reset_selected_index()
            --view.ui.opacity = 0
        end
    end

end)
