
TabView = Class(View, function(view, model,parent, ...)
    view._base.init(view,model)
    view.parent = parent
    view.ui=Group{name="Tab ui", position={425,60}, opacity=255}
    view.menu_items = {}
    view.selector = Image{
        position={-70,0},
        src = "assets/OptionHighlight.png"
    }

    function view:Create_Menu_Items()
        view.menu_items = {}
        --gut the UI
        view.ui:clear()
        view.ui:add(view.selector)
        view.menu_items = view.parent.sub_group_items
        for i, t in ipairs(view.menu_items) do
            view.ui:add(unpack(view.menu_items[i]))
        end
    end

    screen:add(view.ui)
    function view:initialize()
        view:set_controller(TabController(self))
    end

    function view:leave_sub_group()
        --view.parent.menu_items[view.parent:get_controller():get_selected_index()]:animate{duration= 100, opacity = 255}
        --view.parent.sub_group[view.parent:get_controller():get_selected_index()]:animate{duration = 100, opacity = 100}
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
            view.selector.opacity = 255
            for i,option in ipairs(view.menu_items[view.parent:get_controller():get_selected_index()]) do
                for j,item in ipairs(option) do
                    if i == controller:get_selected_index() then
                        view.selector.y = 60*(i-1)
                        --item:animate{duration=100, opacity = 255}
                    else
                        --item:animate{duration=100, opacity = 100}
                    end
                end
            end
        elseif comp == Components.CUSTOMIZE_ITEM then
            print("Greying TabView UI")
            --view.ui.opacity = 100
        else
            print("Hiding TabView UI")
            view.ui.opacity = 0
            view.selector.opacity = 0
        end
    end
    

   end)
