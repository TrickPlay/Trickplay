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
--[[
    view.save = Image{
        position = {1800,-100},
        src      = "assets/SavePizza.png"
    }
    view.yes_sel = Image{
    }
    view.yes_un = Image{}
    view.no_sel = Image{}
    view.no_en  = Image{}
--]]
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
    view.text = {
        Text{
            position={100, 40},
            font  = DEFAULT_FONT,
            color = Colors.BLACK,
            text = "Back"
        },
        Text{
            position={300, 40},
            font  = DEFAULT_FONT,
            color = Colors.BLACK,
            text = "Add to Order"
        },
        Text{
            position={1300, 40},
            font  = DEFAULT_FONT,
            color = Colors.BLACK,
            text = "View Cart & Checkout"
        }

    }
    view.ui:add(view.bar)
    view.ui:add(unpack(view.items_selected))
    view.ui:add(unpack(view.items_unselected))
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
            view.ui.opacity = 255
            view.ui:raise_to_top()
            --if this child had the focus
            if p_controller.curr_comp == p_controller.ChildComponents.FOOT then
                for i=1,#view.items_selected do
                    if i == controller:get_selected_index() then
                        print("\t",i,"opacity to 255")
                        --item:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                        view.items_selected[i].opacity   = 255
                        view.items_unselected[i].opacity = 0
                    else
                        print("\t",i,"opacity to 0")
                        --item:animate{duration=CHANGE_VIEW_TIME, opacity=100}
                        view.items_selected[i].opacity   = 0
                        view.items_unselected[i].opacity = 255
                    end
                end
            --if this child doesn't have the focus
            else
                for i=1,#view.items_selected do
                    --item:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                    view.items_selected[i].opacity   = 0
                    view.items_unselected[i].opacity = 255
                end
            end
        elseif comp ~= Components.TAB and comp ~= Components.CUSTOMIZE_ITEM then
            print("Hiding CustomizeFooterView UI")
            --view.ui:complete_animation()
            view.ui.opacity = 0
        end
    end

end)
