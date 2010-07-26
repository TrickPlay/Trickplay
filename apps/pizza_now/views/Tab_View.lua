DEFAULT_FONT="DejaVu Sans Mono 40px"
DEFAULT_COLOR="FFFFFF" --WHITE
TabView = Class(View, function(view, model, ...)
    view._base.init(view,model)
    
    view.ui=Group{name="Tab ui", position={300,60}, opacity=255}

    view.menu_items = customize_view.sub_group_items
    for i, t in ipairs(view.menu_items) do
        view.ui:add(unpack(view.menu_items[i]))
    end

    screen:add(view.ui)
    function view:initialize()
        view:set_controller(TabController(self))
    end

    function view:leave_sub_group()
        customize_view.sub_group[customize_view:get_controller():get_selected_index()]:animate{duration = 100, opacity = 100}
        model:set_active_component(Components.CUSTOMIZE)
        view:get_controller():reset_selected_index()
        self:get_model():notify()
    end

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Components.TAB then
            print("Showing TabView UI")
            view.ui.opacity = 255
            for i,option in ipairs(view.menu_items[customize_view:get_controller():get_selected_index()]) do
                for j,item in ipairs(option) do
                    if i == controller:get_selected_index() then
                        item:animate{duration=100, opacity = 255}
                    else
                        item:animate{duration=100, opacity = 100}
                    end
                end
            end
        elseif comp == Components.CUSTOMIZE then
            print("Greying TabView UI")
            view.ui.opacity = 100
        else
            print("Hiding TabView UI")
            view.ui.opacity = 0
        end
    end
    

   end)
