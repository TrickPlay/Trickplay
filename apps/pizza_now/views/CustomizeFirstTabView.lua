CustomizeFirstTabView = Class(View, function(view, model,parent, ...)
    view._base.init(view, model)
    view.parent = parent
    view.selector = Image{
        opacity = 0,
        src = "assets/RadioOn.png"
    }
    screen:add(view.selector)
    view.ui=Group{name="customize first tab ui", position={0,960}, opacity=255}
    function view:initialize()
        self:set_controller(CustomizeFirstTabController(self))
    end
    --function view:initing()
        --view.menu_items = view.parent.first_tab_groups
    --end
    function view:update()
        local controller = view:get_controller()
        local p_controller = view.parent:get_controller()
        local comp = model:get_active_component()
        if comp == Components.CUSTOMIZE then
            print("Showing CustomizeFirstTabView UI")
            --view.ui.opacity = 255
            --view.ui:raise_to_top()
            --if this child had the focus
            local sel = controller:get_selected_index()
            if p_controller.curr_comp == p_controller.ChildComponents.FIRST_TAB then
                if controller.in_tab then
                    view.selector.opacity = 100
                    view.selector:raise_to_top()
                    for i=1,#view.parent.first_tab_groups[sel[1]][sel[2]] do
                        if i == controller:get_in_tab_index() then
                            view.parent.first_tab_groups[sel[1]][sel[2]][i][1].color = "602020"
                            view.selector.x = view.parent.first_tab_groups[sel[1]][sel[2]][i][2].x + view.parent.sub_group[1].x
                            view.selector.y = view.parent.first_tab_groups[sel[1]][sel[2]][i][2].y + view.parent.sub_group[1].y
                        else
                            view.parent.first_tab_groups[sel[1]][sel[2]][i][1].color = Colors.BLACK
                        end
                    end
                else
                    view.selector.opacity = 0
                    for i=1,#view.parent.first_tab_groups do
                        for j=1,#view.parent.first_tab_groups[i] do
                            if i == sel[1] and j == sel[2] then
                                print("\t",i,j,"opacity to 255")
                                --item:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                                view.parent.first_tab_groups[i][j][-1].opacity = 255
                                view.parent.first_tab_groups[i][j][-2].color = "602020"
                            else
                                print("\t",i,j,"opacity to 0")
                                --item:animate{duration=CHANGE_VIEW_TIME, opacity=100}
                                view.parent.first_tab_groups[i][j][-1].opacity = 0
                                view.parent.first_tab_groups[i][j][-2].color = Colors.BLACK
                            end
                        end
                    end
                end 
            --if this child doesn't have the focus
            else
                --if view.menu_items ~= nil then
                for i=1,#view.parent.first_tab_groups do
                    for j=1,#view.parent.first_tab_groups[i] do
                        --if i == sel[1] and j == sel[2] then
                    --item:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                            view.parent.first_tab_groups[i][j][-1].opacity = 0
                            view.parent.first_tab_groups[i][j][-2].color = Colors.BLACK
                       -- end
                    end
                end
                --end
            end
        else
            print("Hiding CustomizeFirstTabView UI")
            --view.ui:complete_animation()
            view.ui.opacity = 0
        end
    end

end)
