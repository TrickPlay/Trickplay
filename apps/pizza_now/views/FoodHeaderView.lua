FoodHeaderView = Class(View, function(view, model, ...)
    view._base.init(view,model)

    local deliveryOrPickup = Text{
        position={0,0},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        text = "first item",
        wants_enter = false
    }
    local arrivalTime = Text{
        position = {600, 0},
        font=DEFAULT_FONT,
        color = DEFAULT_COLOR,
        text = "second item"
    }
    local sort = Text{
        position={1200,0},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        text="third item"
    }

    view.options = {deliveryOrPickup, arrivalTime, sort}
    view.ui = Group{name="Food Header UI", position={10, 10}, opacity=255}
    view.ui:add(unpack(view.options))
    assert(view.ui.children[1])
    --screen:add(view.ui)

    function view:initialize()
        self:set_controller(FoodHeaderController(self))
    end

    function view:update()
        local controller = self:get_controller()
        local comp = model:get_active_component()
        if comp == Components.FOOD_SELECTION then
            print("Showing Food Header View UI")
            for i,item in ipairs(self.options) do
                if i == controller:get_selected_index() then
                    item:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                else
                    item:animate{duration=CHANGE_VIEW_TIME, opacity=100}
                end
            end

        else
            print("Hiding Food Header View UI")
            self.ui:complete_animation()
            self.ui.opacity = 0
        end
    end

end)
