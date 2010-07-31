FinalOrderView = Class(View, function(view, model, parent_view, ...)
    view._base.init(view, model)

    view.parent_view = parent_view

    local editOrder = Image{
        position={375,445},
        src = "assets/EditOrderHighlight.png"
    }
    addCoupon = Image{
        position = {375,535},
        src = "assets/EditOrderHighlight.png"
    }

    view.options = {editOrder, addCoupon}
    view.ui = Group{name="finalOrder_ui", position={10, 10}, opacity=255}
    view.ui:add(unpack(view.options))
    assert(view.ui.children[1])

    function view:initialize()
        self:set_controller(FinalOrderController(self))
    end

    function view:update()
        local controller = self:get_controller()
        local comp = model:get_active_component()
        if comp == Components.CHECKOUT then
            print("Showing FinalOrderView UI")
            for i,item in ipairs(self.options) do
                if i == controller:get_selected_index() then
                    item:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                else
                    item:animate{duration=CHANGE_VIEW_TIME, opacity=0}
                end
            end
        else
            print("Hiding FinalOrderView UI")
            self.ui:complete_animation()
            self.ui.opacity = 0
        end
    end

end)
