DeliveryOptionsView = Class(View, function(view, model, ...)
    view._base.init(view,model)

    local deliveryOrPickup = Text{
        position={0,0},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        text="Delivery or Pickup",
        wants_enter = false
    }
    local arrivalTime = Text{
        position = {600, 0},
        font=DEFAULT_FONT,
        color = DEFAULT_COLOR,
        text = "Arrival Time: "..model.arrival_time
    }
    local sort = Text{
        position={1200,0},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        text="Sort"
    }

    view.options = {deliveryOrPickup, arrivalTime, sort}
    view.ui = Group{name="deliveryOptions_ui", position={10, 10}, opacity=255}
    view.ui:add(unpack(view.options))
    assert(view.ui.children[1])
    screen:add(view.ui)

    function view:initialize()
        self:set_controller(DeliveryOptionsController(self))
    end

    function view:update()
        local controller = self:get_controller()
        local comp = model:get_active_component()
        if comp == Components.PROVIDER_SELECTION then
            print("Showing DeliveryOptionsView UI")
            for i,item in ipairs(self.options) do
                if i == controller:get_selected_index() then
                    item:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                else
                    item:animate{duration=CHANGE_VIEW_TIME, opacity=100}
                end
            end

            arrivalTime.text = "Arrival Time: "..model.arrival_time
        else
            print("Hiding DeliveryOptionsView UI")
            self.ui:complete_animation()
            self.ui.opacity = 0
        end
    end

end)
