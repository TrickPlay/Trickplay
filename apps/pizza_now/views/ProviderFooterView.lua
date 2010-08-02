local DEFAULT_FONT = CUSTOMIZE_ENTRY_FONT
local DEFAULT_COLOR = Colors.BLACK

ProviderFooterView = Class(View, function(view, model, ...)
    view._base.init(view, model)
     
    view.ui=Group{name="providerfooter_ui", position={0,0}, opacity=255}

    view.items = {
        Text{
            position={0, 1000},
            font  = DEFAULT_FONT,
            color = DEFAULT_COLOR,
            text = "Exit"
        },
        Text{
            position={700, 975},
            font=DEFAULT_FONT,
            color=DEFAULT_COLOR,
            text="Enter Street",
            wants_enter = false,
            max_length = 20
        },
        Text{
            position={700,1030},
            font=DEFAULT_FONT,
            color=DEFAULT_COLOR,
            wants_enter = false,
            text="City",
            max_length = 15
        },
        Text{
            position={1090,1030},
            font=DEFAULT_FONT,
            color=DEFAULT_COLOR,
            wants_enter = false,
            text="CA",
            max_length = 2
        },
        Text{
            position={1180,1030},
            font=DEFAULT_FONT,
            color=DEFAULT_COLOR,
            wants_enter = false,
            text="ZIP",
            max_length = 5
        },
        Text{
            position={1570, 1000},
            font  = DEFAULT_FONT,
            color = DEFAULT_COLOR,
            text = "Continue"
        },
    }
    view.ui:add(unpack(view.items))
    --screen:add(view.ui)
    function view:initialize()
        self:set_controller(ProviderFooterController(self))
    end

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Components.PROVIDER_SELECTION then
            print("Showing ProviderFooterView UI")
--            view.ui.opacity = 255
            view.ui:raise_to_top()
            for i,item in ipairs(view.items) do
                if i == controller:get_selected_index() then
                    print("\t",i,"opacity to 255")
                    item:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                else
                    print("\t",i,"opacity to 0")
                    item:animate{duration=CHANGE_VIEW_TIME, opacity=100}
                end
            end
        else
            print("Hiding ProviderFooterView UI")
            view.ui:complete_animation()
            view.ui.opacity = 0
        end
    end

end)
