DEFAULT_FONT="DejaVu Sans Mono 40px"
DEFAULT_COLOR="FFFFFF" --WHITE
TopLevelView = Class(View, function(view, model, ...)
    view._base.init(view,model)
     
    view.umbrella_ui=Group{name="umbrella ui", position={10,10}, opacity=0}

    header_view = HeaderView(model)
    header_view:initialize()
    carousel_view = CarouselView(model)
    carousel_view:initialize()
    footer_view = FooterView(model)
    footer_view:initialize()

    local umbrella_items = {
        header_view,
        carousel_view,
        footer_view
    }
    view.umbrella_ui:add(unpack(umbrella_items))
    screen:add(view.umbrella_ui)
    function view:initialize()
        self:set_controller(TopLevelController(self))
    end
    local prev_selection = {}
    for i = 1, #umbrella_items do
        prev_selection[i] = 1
    end
    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Component.FOOD then
            print("Showing HeaderView UI")
            view.umbrella_ui.opacity = 255
            for i,c_view in ipairs(umbrella_items) do
                if i == controller:get_selected_index() then
                    c_view.ui:animate{duration=1000, opacity=255}
                    c_view.menu_items[prev_selection[i]]:animate{duration=1000, opacity=255}
                    view:get_controller().child = c_view:get_controller()
                else
                    print("opacity to 0")
                    c_view.ui:animate{duration=1000, opacity=100}
                    prev_selection[i] = c_view:get_controller():get_selected_index()
                end
            end
        else
            print("Hiding HeaderView UI")
            view.umbrella_ui.opacity = 0
        end
    end

   end)
