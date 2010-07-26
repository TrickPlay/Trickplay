DEFAULT_FONT="DejaVu Sans Mono 40px"
DEFAULT_COLOR="FFFFFF" --WHITE
FooterView = Class(View, function(view, model, ...)
    view._base.init(view, model)
     
    view.ui=Group{name="footer ui", position={10,1000}, opacity=255}

    view.items = {
        Text{
            position={0, 0},
            font  = DEFAULT_FONT,
            color = DEFAULT_COLOR,
            text = "Go Back"
        },
        Text{
            position={1200, 0},
            font  = DEFAULT_FONT,
            color = DEFAULT_COLOR,
            text = "Continue"
        }
    }
    view.ui:add(unpack(view.items))
    screen:add(view.ui)
    function view:initialize()
        self:set_controller(FooterController(self))
    end

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Components.PROVIDER_SELECTION then
            print("Showing FooterView UI")
--            view.ui.opacity = 255
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
            print("Hiding HeaderView UI")
            view.ui:complete_animation()
            view.ui.opacity = 0
        end
    end

end)
