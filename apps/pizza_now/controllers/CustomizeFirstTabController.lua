CustomizeFirstTabController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.CUSTOMIZE)

--[[
    local MenuItems = {
        GO_BACK = 1,
        ADD = 2
    }
    
    local MenuSize = 0
    for k, v in pairs(MenuItems) do
        MenuSize = MenuSize + 1
    end
--]]
    -- the default selected index
    local selected = {1,1}
    local in_tab_selected = 1
    


    local tabs_mapping = {}
    function self:refresh_mapping()
    tabs_mapping = {}
    tabs_mapping[1] = {function (x) self:get_model().current_item.Tabs[1].Options[1].Placement = x end,
                       function (x) self:get_model().current_item.Tabs[1].Options[1].CoverageX = x+1 end}
    tabs_mapping[2] = {function (x) self:get_model().current_item.Tabs[1].Options[3].Crust_Style = x 
         view.parent.ingredientbox_top = All_Options.Size_r[model.current_item.Tabs[1].Options[4].Size].." "..
                                         All_Options.Crust_Style_r[model.current_item.Tabs[1].Options[3].Crust_Style].." "..
                                         model.current_item.Name
         view.parent:rebuild_ingredient_box()
end,
                       function (x) self:get_model().current_item.Tabs[1].Options[4].Size = x 
         view.parent.ingredientbox_top = All_Options.Size_r[model.current_item.Tabs[1].Options[4].Size].." "..
                                         All_Options.Crust_Style_r[model.current_item.Tabs[1].Options[3].Crust_Style].." "..
                                         model.current_item.Name
         view.parent:rebuild_ingredient_box()

end}
    tabs_mapping[3] = {function (x) self:get_model().current_item.Tabs[1].Options[2].Sauce_Type = x end}
    end
    local MenuKeyTable = {
        [keys.Up]    = function(self) self:move_selector(Directions.UP) end,
        [keys.Down]  = function(self) self:move_selector(Directions.DOWN) end,
        [keys.Left]  = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
        [keys.Return] = function(self)
            if self.in_tab then
                view.parent.first_tab_groups[selected[1]][selected[2]][-2].color = "602020"
                self.in_tab = false
                    for i=1,#view.parent.first_tab_groups[selected[1]][selected[2]] do
                        if i == in_tab_selected then
                            view.parent.first_tab_groups[selected[1]][selected[2]][i][2].opacity = 255
                            view.parent.first_tab_groups[selected[1]][selected[2]][i][3].opacity = 0
                            assert(tabs_mapping,"1")
                            assert(tabs_mapping[selected[1]],"2")
                            assert(tabs_mapping[selected[1]][selected[2]],"3")
                            tabs_mapping[selected[1]][selected[2]](i)
                        else
                            print(selected[1],selected[2],i,2)
                            view.parent.first_tab_groups[selected[1]][selected[2]][i][2].opacity = 0
                            view.parent.first_tab_groups[selected[1]][selected[2]][i][3].opacity = 255
                        end
                            view.parent.first_tab_groups[selected[1]][selected[2]][i][1].color = Colors.BLACK
                        if selected[1] == 2 and selected[2] == 2 then
                            view.parent.first_tab_groups[2][2][i][4].opacity = 0
                            view.parent.first_tab_groups[2][2][i][1].opacity = 255
                            
                        end

                    end
            else
                view.parent.first_tab_groups[selected[1]][selected[2]][-2].color = Colors.BLACK
                self.in_tab = true
                in_tab_selected = 1
            end
            self:get_model():notify()
--[[
            local success, error_msg = pcall(MenuItemCallbacks[selected], self)
            if not success then print(error_msg) end
--]]
        end
    }

    function self:on_key_down(k)
        if MenuKeyTable[k] then
            MenuKeyTable[k](self)
        end
    end

    function self:get_in_tab_index()
        return in_tab_selected
    end

    function self:get_selected_index()
        return selected
    end

    self.in_tab = false

    function self:move_selector(dir)
        if self.in_tab then
            local new_in_tab_selected = in_tab_selected + dir[2]
            if view.parent.first_tab_groups[selected[1]][selected[2]][new_in_tab_selected] ~= nil then
                in_tab_selected = new_in_tab_selected
            end
        else
            local new_selected = {selected[1] + dir[2],
                                  selected[2] + dir[1]}
            if selected[2] == 1 and dir == Directions.LEFT then
                print("Moving back to the tab bar")
                view.parent:get_controller().curr_comp = view.parent:get_controller().ChildComponents.TAB_BAR
            elseif new_selected[1] == 3 and new_selected[2] == 2 then
                selected[1] = 2
                selected[2] = 2
            elseif view.parent.first_tab_groups[new_selected[1]] ~= nil and
                   view.parent.first_tab_groups[new_selected[1]][new_selected[2]] ~= nil then
                selected[1] = new_selected[1]
                selected[2] = new_selected[2]
            end
            print("Moving to ",selected[1],selected[2])
        end
        self:get_model():notify()
    end
end)
