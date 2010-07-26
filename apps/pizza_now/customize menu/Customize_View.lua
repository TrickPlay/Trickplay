DEFAULT_FONT="DejaVu Sans Mono 40px"
DEFAULT_COLOR="FFFFFF" --WHITE
CustomizeView = Class(View, function(view, model, food_item, ...)
    view._base.init(view,model)
     
    view.ui=Group{name="Tab ui", position={10,60}, opacity=255}

    view.item = food_item
    view.menu_items      = {}
    view.sub_group       = {}
    view.sub_group_items = {}
    

----------------------------------------------------------------------------
    --Build Tabs and their sub groups
    function view:Create_Menu_Items()
    for tab_index,tab in ipairs(view.item.Tabs) do
         
        view.menu_items[tab_index] = Text {
            position = {0, 80*(tab_index-1)},
            font     = DEFAULT_FONT,
            color    = DEFAULT_COLOR,
            text     = tab.Tab_Text
        }
        view.sub_group_items[tab_index] = {}
        view.sub_group[tab_index] = Group{name="Tab ",tab_index," sub-group",
                                                position={400,60}, opacity=0}
        if tab.Options ~= nil then
            for opt_index,option in ipairs(tab.Options) do
                local indent = 1
                view.sub_group_items[tab_index][opt_index] = {}
                view.sub_group_items[tab_index][opt_index][indent] = Text {
                    position = {0, 60*(opt_index-1)},
                    font     = DEFAULT_FONT,
                    color    = DEFAULT_COLOR,
                    text     = option.Name
                }
                view.sub_group[tab_index]:add(view.sub_group_items[tab_index][opt_index][indent])
                for item, selection in pairs(option) do
                    if item ~= "Name" and item ~= "Image" then
                        indent = indent + 1
                        for pick, val in pairs(All_Options[item]) do
                            if val == selection then
                            view.sub_group_items[tab_index][opt_index][indent] = Text {
                                position = {400*(indent-1), 60*(opt_index-1)},
                                font     = DEFAULT_FONT,
                                color    = DEFAULT_COLOR,
                                text     = pick
                            }
                            view.sub_group[tab_index]:add(view.sub_group_items[tab_index][opt_index][indent])
                            end
                        end
                    end
                end
            end
        end
        screen:add(view.sub_group[tab_index])

    end
    end
    view:Create_Menu_Items()
----------------------------------------------------------------------------
    view.ui:add(unpack(view.menu_items))
    screen:add(view.ui)

    function view:initialize()
        view:set_controller(CustomizeController(self))
        view.initialize = nil
    end

    function view:enter_sub_group()
        --view.menu_items[view:get_controller():get_selected_index()]:animate{duration=500, opacity = 100}
        view.sub_group[view:get_controller():get_selected_index()]:animate{duration = 100, opacity = 255}
        model:set_active_component(Component.TAB)
        --print("entering sub group")

        self:get_model():notify()
    end

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        --print("Active Component: "..comp)
        if comp == Component.CUSTOMIZE then
            print("Showing CustomizeView UI")
            view.ui.opacity = 255
            for i,item in ipairs(view.menu_items) do
                if i == controller:get_selected_index() then
                    --print("\t",i,"opacity to 255")
                    item:animate{duration=100, opacity = 255}
                    view.sub_group[i]:animate{duration = 100, opacity = 100}
                else
                    --print("\t",i,"opacity to 0")
                    item:animate{duration=100, opacity = 100}
                    view.sub_group[i]:animate{duration = 100, opacity = 0}
                end
            end
        elseif comp == Component.TAB then
            print("Greying CustomizeView UI")
            view.ui.opacity = 100
        else
            print("Hiding CustomizeView UI")
            view.ui.opacity = 0
        end
    end

   end)
