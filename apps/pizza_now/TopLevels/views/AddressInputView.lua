AddressInputView = Class(View, function(view, model, ...)
    view._base.init(view,model)

    local back = Image{
        position = {0,0},
        src = "assets/MenuBg.jpg"
    }
    local junkInDaTrunk = Clone{source = back}
    junkInDaTrunk.position = {960, 0}
    local verticalDividerLeft = Image{
        position = {150,0},
        height = 960,
        tile = {false, true},
        src = "assets/MenuLine.png"
    }
    local background = {back, junkInDaTrunk}

    local street = Text{
        position={50,0},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        editable = true,
        text="Enter Street",
        wants_enter = false
    }
    local apartment = Text{
        position = {400, 0},
        font=DEFAULT_FONT,
        color = DEFAULT_COLOR,
        editable = true,
        text = "Apt."
    }
    local city = Text{
        position={50,60},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        editable = true,
        text="City"
    }
    local zip_code = Text{
        position={50,120},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        editable = true,
        text="Zip Code"
    }
    local confirm = Text{
        position={50, 180},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        text = "Confirm Address?"
    }
    local exit = Text{
        position={50, 240},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        text = "Exit App?"
    }

    local menu_items = {street, apartment, city, zip_code, confirm, exit}
    view.entry_ui = Group{name = "addressEntry_ui", position = {660, 180}}
    view.entry_ui:add(unpack(menu_items))
    view.static_ui = Group{name = "addressStatic_ui", position = {0,0}}
    view.static_ui:add(unpack(background))
    view.ui=Group{name="address_ui", position={0,0}, opacity=0}
    view.ui:add(view.static_ui, view.entry_ui)
    screen:add(view.ui)

    function view:initialize()
        self:set_controller(AddressInputController(self))
    end

    function view:update()
        local controller = self:get_controller()
        local comp = self.model:get_active_component()
        if comp == Components.ADDRESS_INPUT then
            print("Showing AddressInputView UI")
            self.ui.opacity = 255
            for i,item in ipairs(menu_items) do
                if i == controller:get_selected_index() then
                    item:animate{duration=1000, mode="EASE_OUT_EXPO", opacity=255}
                else
                    item:animate{duration=1000, mode="EASE_OUT_BOUNCE", opacity=0}
                end
            end
        else
            print("Hiding AddressInputView UI")
            self.ui.opacity = 0
        end
    end

end)
