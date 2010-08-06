CustomizeFooterView = Class(View, function(view, model,parent, ...)
    view._base.init(view, model)
    view.parent = parent
    view.ui=Group{name="customize_footer_ui", position={0,960}, opacity=255}
    view.bar = Image{
                position = {0,0},
                width = 1920,
                tile = {false,true},
                src="assets/OrderBarBase.png"
    }
    
    view.save = Image{
        position = {0,0},
        src      = "assets/SavePizza.png"
    }
    view.yes_sel = Image{
        position = {50,100},
        src      = "assets/SavePizza_YesFocus.png"
    }
    view.yes_unsel = Image{
        position = {50,100},
        src      = "assets/SavePizza_Yes.png"
    }
    view.no_sel = Image{
        position = {190,100},
        src      = "assets/SavePizza_NoFocus.png"
    }
    view.no_unsel  = Image{
        position = {190,100},
        src      = "assets/SavePizza_No.png"
    }
    view.areyousure = Group{name="Are You Sure",
                            position = {1500,-250},
                            opacity = 0}
    view.ui:add(view.areyousure)
    view.areyousure:add(view.save)
    view.areyousure:add(view.yes_sel)
    view.areyousure:add(view.yes_unsel)
    view.areyousure:add(view.no_sel)
    fthis = view.ui 
    view.areyousure:add(view.no_unsel)
    view.focusable_items = {
        FocusableImage(30,30,
         "assets/BackArrow.png",
         "assets/BackArrowFocus.png"),
        FocusableImage(250,30,
         "assets/AddButton.png",
         "assets/AddButtonFocus.png"),
        FocusableImage(1700,30,
         "assets/CartButton.png",
         "assets/CartButtonFocus.png"),
    }
--[[
    view.items_selected = {
        Image{
            position={0, 20},
            src = "assets/BackArrowFocus.png"
        },
        Image{
            position={200, 20},
            src = "assets/AddButtonFocus.png"
        },
        Image{
            position={1800, 20},
            src = "assets/CartButtonFocus.png"
        }

    }
    view.items_unselected = {
        Image{
            position={0, 20},
            src = "assets/BackArrow.png"
        },
        Image{
            position={200, 20},
            src = "assets/AddButton.png"
        },
        Image{
            position={1800, 20},
            src = "assets/CartButton.png"
        }

    }
--]]
    view.text = {
        Text{
            position={0, 0},
            font  = CUSTOMIZE_ENTRY_FONT,
            color = Colors.BLACK,
            text = "Go Back"
        },
        Text{
            position={250, 0},
            font  = CUSTOMIZE_ENTRY_FONT,
            color = Colors.BLACK,
            text = "Add to Order"
        },
        Text{
            position={1700, 0},
            font  = CUSTOMIZE_ENTRY_FONT,
            color = Colors.BLACK,
            text = "Checkout"
        }

    }
    view.ui:add(view.bar)
    --view.ui:add(unpack(view.items_selected))
    --view.ui:add(unpack(view.items_unselected))
    view.ui:add(view.focusable_items[1].group)
    view.ui:add(view.focusable_items[2].group)
    view.ui:add(view.focusable_items[3].group)


    view.ui:add(unpack(view.text))
    screen:add(view.ui)
    function view:initialize()
        self:set_controller(CustomizeFooterController(self))
    end

    function view:update()
        local controller = view:get_controller()
        local p_controller = view.parent:get_controller()
        local comp = model:get_active_component()
        if comp == Components.CUSTOMIZE then
            print("Showing CustomizeFooterView UI")
            --view.ui.opacity = 255
            view.ui:raise_to_top()
            --if this child had the focus
            if p_controller.curr_comp == p_controller.ChildComponents.FOOT then
                view.ui:animate{duration=CHANGE_VIEW_TIME,opacity = 255}

                if controller.areyousure then
                    view.areyousure.opacity = 255
                    if controller:get_YNselected_index() == 1 then
                        view.yes_sel.opacity   = 255
                        view.yes_unsel.opacity = 0
                        view.no_sel.opacity    = 0
                        view.no_unsel.opacity  = 255
                    else
                        view.yes_sel.opacity   = 0
                        view.yes_unsel.opacity = 255
                        view.no_sel.opacity    = 255
                        view.no_unsel.opacity  = 0
                    end
                else
                    view.areyousure.opacity = 0
                    for i=1,#view.focusable_items do
                        if i == controller:get_selected_index() then
                            print("\t",i,"opacity to 255")
                            --item:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                            view.focusable_items[i]:on_focus()
                            --view.items_selected[i].opacity   = 255
                            --view.items_unselected[i].opacity = 0
                        else
                            print("\t",i,"opacity to 0")
                            --item:animate{duration=CHANGE_VIEW_TIME, opacity=100}
                            view.focusable_items[i]:out_focus()
                            --view.items_selected[i].opacity   = 0
                            --view.items_unselected[i].opacity = 255
                        end
                    end
                end
            --if this child doesn't have the focus
            else
                for i=1,#view.focusable_items do
                    --item:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                    view.focusable_items[i]:out_focus()
                    --view.items_selected[i].opacity   = 0
                    --view.items_unselected[i].opacity = 255
                end
                view.ui:animate{duration=CHANGE_VIEW_TIME,opacity = BACKGROUND_FADE_OPACITY}
            end
        elseif comp ~= Components.TAB and comp ~= Components.CUSTOMIZE_ITEM then
            print("Hiding CustomizeFooterView UI")
            view.ui:complete_animation()
            view.ui.opacity = 0
        end
    end

end)
