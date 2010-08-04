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
        position = {990,30},
        font = CUSTOMIZE_TINY_FONT,
        color = Colors.BLACK,
        text = "Please have your legal photo ID and\ncredit card available for verification.",
    }
    local termsText = Text{
        position = {20, 30},
        font = CUSTOMIZE_TINY_FONT,
        color = Colors.BLACK,
        text = "By ordering, I implicitly agree to the Terms and\nConditions of Domino's Pizza and Pizza Now."
    }
    view.background_ui:add(orderBar, creditInstructionsText, termsText)
    view.items = {
        Text{
            position={1610, 40},
            font  = CUSTOMIZE_TAB_FONT,
            color = Colors.BLACK,
            text = "Place Order"
        }
    }
    view.entry_ui:add(unpack(view.items))
    view.ui:add(view.background_ui, view.entry_ui)
    function view:initialize()
        self:set_controller(FinalFooterController(self))
    end

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Components.CHECKOUT then
            print("Showing FinalFooterView UI")
--            view.ui.opacity = 255
            for i,item in ipairs(view.items) do
                if i == controller:get_selected_index() then
                    item:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                    item.color = Colors.RED
                else
                    item:animate{duration=CHANGE_VIEW_TIME, opacity=100}
                    item.color = Colors.BLACK
                end
            end
        else
            print("Hiding FinalFooterView UI")
            view.ui:complete_animation()
            view.ui.opacity = 0
        end
    end

end)
