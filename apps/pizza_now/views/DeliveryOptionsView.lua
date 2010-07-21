DeliveryOptionsView = Class(View, function(view, model, ...)
    view._base.init(view,model)

    local deliveryOrPickup = Text{
        position={50,0},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        editable = true,
        text="Enter Street",
        wants_enter = false
    }
    local arrivalTime = Text{
        position = {400, 0},
        font=DEFAULT_FONT,
        color = DEFAULT_COLOR,
        editable = true,
        text = "Apt."
    }
    local sort = Text{
        position={50,60},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        editable = true,
        text="City"
    }

    local options = {street, apartment, city, zip_code, confirm, exit}
    view.deliveryOptions_ui=Group{name="address_ui", position={660,180}, opacity=0}
    view.address_ui:add(unpack(menu_items))
    assert(view.address_ui.children[1])
    screen:add(view.address_ui)

    function view:initialize()
        self:set_controller(AddressInputController(self))
    end

    function view:update()
        local controller = self:get_controller()
        local comp = self.model:get_active_component()
        if comp == Components.ADDRESS_INPUT then
            print("Showing AddressInputView UI")
            self.address_ui.opacity = 255
            for i,item in ipairs(menu_items) do
                if i == controller:get_selected_index() then
                    item:animate{duration=1000, mode="EASE_OUT_EXPO", opacity=255}
                else
                    item:animate{duration=1000, mode="EASE_OUT_BOUNCE", opacity=0}
                end
            end
        else
            print("Hiding AddressInputView UI")
            self.address_ui.opacity = 0
        end
    end

end)
