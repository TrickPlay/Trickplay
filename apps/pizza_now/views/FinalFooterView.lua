FinalFooterView = Class(View, function(view, model, parent_view, ...)
    view._base.init(view, model)

    view.parent_view = parent_view
     
    view.ui=Group{name="finalFooter_ui", position={0,960}}
    view.background_ui=Group{name="finalFooterBackground_ui", position={0,0}}
    view.entry_ui=Group{name="finalFooterEntry_ui", position={0,0}, opacity=255}

    local orderBar = Image{
        src = "assets/OrderBarBase.png",
        position = {0, 0},
        tile = {true, false},
        width = 1920
    }
    local creditInstructionsText = Text{
        position = {170,60},
        font = CUSTOMIZE_TINY_FONT,
        color = Colors.BLACK,
        text = "Please have your legal photo ID and credit card available for verification.",
    }
    local termsText = Text{
        position = {170, 30},
        font = CUSTOMIZE_TINY_FONT,
        color = Colors.BLACK,
        text = "By ordering, I implicitly agree to the Terms and Conditions of Domino's Pizza and Pizza Now."
    }
    view.background_ui:add(orderBar, creditInstructionsText, termsText)
    view.items = {
        {
            Image{
                position={30, 30},
                src = "assets/BackArrow.png"
            },
            Image{
                position={30, 30},
                src = "assets/BackArrowFocus.png"
            }
        },
        {
            Text{
                position={1610, 40},
                font  = CUSTOMIZE_TAB_FONT,
                color = Colors.BLACK,
                text = "Place Order"
            },
            Text{
                position={1610, 40},
                font  = CUSTOMIZE_TAB_FONT,
                color = Colors.RED,
                text = "Place Order"
            }
        },
    }
    items = view.items
    view.entry_ui:add(unpack(view.items[1]))
    view.entry_ui:add(unpack(view.items[2]))
    view.ui:add(view.background_ui, view.entry_ui)
    function view:initialize()
        self:set_controller(FinalFooterController(self))
    end

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Components.CHECKOUT then
            print("Showing FinalFooterView UI")
            for i,item in ipairs(view.items) do
                if i == controller:get_selected_index() then
                    item[2]:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                    item[1]:animate{duration=CHANGE_VIEW_TIME, opacity=0}
                else
                    item[1]:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                    item[2]:animate{duration=CHANGE_VIEW_TIME, opacity=0}
                end
            end
        else
            print("Hiding FinalFooterView UI")
            view.ui:complete_animation()
            view.ui.opacity = 0
        end
    end

end)
