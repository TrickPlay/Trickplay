TabController = Class(Controller,
    function(self, view, ...)
        self._base.init(self, view, Components.TAB)

        -- the default selected index
        local selected = {}
        local i = 1

        local MenuItemCallbacks = {}

        function self:init_shit()
            view:Create_Menu_Items()
            MenuItemCallbacks = {}
            for tab_index,tab in ipairs(view:get_model().current_item.Tabs) do
                MenuItemCallbacks[tab_index] = {}
                if tab.Options ~= nil then
                    for opt_index,option in ipairs(tab.Options) do
                        MenuItemCallbacks[tab_index][opt_index] = option.Selected
                        i = i + 1
                    end
                end
                selected[tab_index] = 1
            end
        end

        local MenuKeyTable = {
         [keys.Up]    = function(self) self:move_selector(Directions.UP) end,
         [keys.Down]  = function(self) self:move_selector(Directions.DOWN) end,
         [keys.Left]  = function(self) self:move_selector(Directions.LEFT) end,
         [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,

         [keys.Return] = 
             function(self)
                 print("\n\n\nreturn registered in Tab Controller")
                 assert(MenuItemCallbacks,
                       "MenuItemCallbacks is nil")
                 assert(MenuItemCallbacks[view.parent:get_controller():get_selected_index()],
                       "MenuItemCallbacks[view.parent:get_controller():get_selected_index()] is nil")
                 assert(MenuItemCallbacks[view.parent:get_controller():get_selected_index()][selected],
                       "MenuItemCallbacks[view.parent:get_controller():get_selected_index()][selected] is nil")
                 local p_ind = view.parent:get_controller():get_selected_index()
                 local y = view.parent.sub_group[p_ind].y+view.parent.sub_group_items[p_ind][selected][1].y
                 print("y",y)
                 MenuItemCallbacks[p_ind][selected](self,y-150)
             end
--[[
            function(self)
             
             self:get_model():set_active_component(Components.CUSTOMIZE_ITEM)
             self:get_model():notify()
            end
--]]
        }

        function self:on_key_down(k)
            if MenuKeyTable[k] then MenuKeyTable[k](self) end
        end

        function self:get_selected_index()
            return selected[view.parent:get_controller():get_selected_index()]
        end
        function self:reset_selected_index()
            selected[view.parent:get_controller():get_selected_index()] = 1
        end

        function self:move_selector(dir)
            local tab_ind = view.parent:get_controller():get_selected_index()
            --move out of the Tab sub group
            if dir == Directions.LEFT then
                view.parent:get_controller().in_tab_group = false
                view:leave_sub_group()
            --move up and down through the options
            elseif dir[2] ~= 0 then
                local new_selected = selected[tab_ind] + dir[2]
                if 1 <= new_selected and new_selected <= #view.menu_items[tab_ind] then
                    selected[tab_ind] = new_selected
                    if dir == Directions.UP then view:move_selector_up(selected[tab_ind])
                    else                         view:move_selector_down(selected[tab_ind]) end
                --if you moved down, but couldn't then drop to the bottom bar
                elseif dir == Directions.DOWN then
                    view.parent:get_controller().prev_comp = view.parent:get_controller().ChildComponents.TAB_ITEMS
                    view.parent:get_controller().curr_comp = view.parent:get_controller().ChildComponents.FOOT
                    --view.parent:get_controller().in_tab_group = false
                    view:leave_sub_group()
                end

                --MenuItemCallbacks[view.parent:get_controller():get_selected_index()][selected]()
                self:get_model():notify()
            end
         
        end
    end)
