FinalFooterView = Class(View, function(view, model, parent_view, ...)
    view._base.init(view, model)

    view.parent_view = parent_view
     
    view.ui=Group{name="finalFooter_ui", position={10,1000}, opacity=255}

    view.items = {
        Text{
            position={1600, 0},
            font  = CUSTOMIZE_TAB_FONT,
            color = Colors.BLACK,
            text = "Place Order"
        }
    }
    view.ui:add(unpack(view.items))
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
                else
                    item:animate{duration=CHANGE_VIEW_TIME, opacity=100}
                end
            end
        else
            print("Hiding FinalFooterView UI")
            view.ui:complete_animation()
            view.ui.opacity = 0
        end
    end

end)
