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
        --customize_view.menu_items[customize_view:get_controller():get_selected_index()]:animate{duration=500, opacity = 255}
        customize_view.sub_group[customize_view:get_controller():get_selected_index()]:animate{duration = 100, opacity = 100}
        model:set_active_component(Component.CUSTOMIZE)
        view:get_controller():reset_selected_index()
        --print("leaving sub group")
    end

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        --print("Active Component: "..comp)
        if comp == Component.TAB then
            print("Showing TabView UI")
            view.ui.opacity = 255
            for i,option in ipairs(view.menu_items[customize_view:get_controller():get_selected_index()]) do
                for j,item in ipairs(option) do
                    if i == controller:get_selected_index() then
                        --print("\t",item.text,"opacity to 255")
                        item:animate{duration=100, opacity = 255}
                        --view.sub_group[i]:animate{duration = 500, opacity = 100}
                    else
                        --print("\t",item.text,"opacity to 0")
                        item:animate{duration=100, opacity = 100}
                        --view.sub_group[i]:animate{duration = 500, opacity = 0}
                    end
                end
            end
        elseif comp == Component.CUSTOMIZE then
            print("Greying TabView UI")
            view.ui.opacity = 100
        else
            print("Hiding TabView UI")
            view.ui.opacity = 0
        end
    end
    

   end)
