local DEFAULT_FONT = CUSTOMIZE_ENTRY_FONT
local DEFAULT_COLOR = Colors.BLACK

ProviderFooterView = Class(View, function(view, model, ...)
    view._base.init(view, model)

    local bottomBar = Image{
        src = "assets/OrderBarBase.png",
        position = {0, 960},
        tile = {true, false},
        width = 1920
    }
     
    view.ui=Group{name="providerfooter_ui", position={0,0}, opacity=255}

    view.exitButtonPress = Image{
        position = {30, 980},
        src = "assets/ExitButtonPress.png",
        opacity = 0
    }
    view.exitItem = FocusableImage(30, 980,
        "assets/ExitButton.png",
        "assets/ExitButtonFocus.png")
    local streetBillingTextBox = TextBox(330, 990, 600)
    local apartmentBillingTextBox = TextBox(950, 990, 120)
    local cityBillingTextBox = TextBox(1090, 990, 370)
    local zipBillingTextBox = TextBox(1480, 990, 120)

    view.boxes = {
        view.exitItem, streetBillingTextBox, apartmentBillingTextBox,
        cityBillingTextBox, zipBillingTextBox
    }

    view.items = {
        Text{
            position={0, 960},
            font  = CUSTOMIZE_ENTRY_FONT,
            color = DEFAULT_COLOR,
            text = "Exit"
        },
        Text{
            position={340, 1000},
            font=DEFAULT_FONT,
            color=DEFAULT_COLOR,
            text="Enter Street",
            wants_enter = false,
            max_length = 26
        },
        Text{
            position={965,1000},
            font=DEFAULT_FONT,
            color=DEFAULT_COLOR,
            wants_enter = false,
            text="Apt.",
            max_length = 5
        },
        Text{
            position={1105,1000},
            font=DEFAULT_FONT,
            color=DEFAULT_COLOR,
            wants_enter = false,
            text="City",
            max_length = 15
        },
        Text{
            position={1495,1000},
            font=DEFAULT_FONT,
            color=DEFAULT_COLOR,
            wants_enter = false,
            text="ZIP",
            max_length = 5
        },
    }

    view.ui:add(bottomBar)
    for i,v in ipairs(view.boxes) do
        view.ui:add(v.group)
    end
    view.ui:add(unpack(view.items))
    view.ui:add(view.exitButtonPress)
    function view:initialize()
        self:set_controller(ProviderFooterController(self))
    end

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Components.PROVIDER_SELECTION then
            print("Showing ProviderFooterView UI")
            view.ui:raise_to_top()
            for i,box in ipairs(view.boxes) do
                if i == controller:get_selected_index() then
                    print("\t",i,"opacity to 255")
                    box.on_focus()
                else
                    print("\t",i,"opacity to 0")
                    box.out_focus()
                end
            end
        else
            print("Hiding ProviderFooterView UI")
            view.ui:complete_animation()
            view.ui.opacity = 0
        end
    end

end)
