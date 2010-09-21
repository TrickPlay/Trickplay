AccordianController = Class(Controller,
    function(self, view, ...)
        self._base.init(self, view, Components.ACCORDIAN)

        -- the default selected index
        local selected = {1,1}
        local i = 1

        local MenuItemCallbacks = {}

        function self:init_shit(accordian_items,tab_index,opt_index,option,acc_g)
            view.menu_items = accordian_items
            --view:Create_Menu_Items()
            MenuItemCallbacks = {}
            for acc_index,acc_sub_g in ipairs(accordian_items) do
                MenuItemCallbacks[acc_index] = {}
                for radio_index,option in ipairs(accordian_items[acc_index]) do
                    MenuItemCallbacks[acc_index][radio_index] = function()
                        print("Option",acc_index,radio_index,"selected out of",#accordian_items[acc_index])
                        for i = 1,#accordian_items[acc_index] do
                            if radio_index == i then
                                print(acc_index,i,"is on")
                                view.menu_items[acc_index][radio_index][2]:unparent() 
                                view.menu_items[acc_index][radio_index][2] = Image {
                                          src      = "assets/RadioOn.png"
                                        }
view.menu_items[acc_index][radio_index][2].y =view.menu_items[acc_index][radio_index][1].y-15
                                view.acc_g:add(view.menu_items[acc_index][radio_index][2])
                                local which = 1
                                for item,curr_selection in pairs(model.current_item.Tabs[tab_index].Options[opt_index]) do
                                   if item ~= "Name" and item ~= "Image" and item ~= "Selected" 
                                      and item ~= "Radio" and item ~= "ToppingGroup" then
                                        if which == acc_index then
                                            print("setting item "..item.." to",radio_index)
                                            model.current_item.Tabs[tab_index].Options[opt_index][item] = radio_index
                                        end
                                        which = which+1
                                    end
                                end
                            else
                                print(acc_index,i,"is off")

                                view.menu_items[acc_index][i][2]:unparent() ---[[
                                view.menu_items[acc_index][i][2] = Image {
                                          src      = "assets/RadioOff.png"
                                        }
view.menu_items[acc_index][i][2].y =view.menu_items[acc_index][i][1].y -15
                                view.acc_g:add(accordian_items[acc_index][i][2])--]]

                            end
                           
                        end
                    end
                    i = i + 1
                end
            end
            self:reset_selected_index()

            view:init_selector(acc_g)
        
        function self:jump_out()  --option.UnSelected
                                                       --function()
            print("\n\nunselecting")
            if opt_index < #model.current_item.Tabs[tab_index].Options then
                for i=opt_index+1,#model.current_item.Tabs[tab_index].Options do
                    view.parent.sub_group_items[tab_index][i][1].y = view.parent.sub_group_items[tab_index][i][1].y - (view.menu_items[#MenuItemCallbacks][#MenuItemCallbacks[#MenuItemCallbacks]][1].y + 50)
                end
            end
            view.parent.accordian_group[tab_index][opt_index].opacity = 0
            model:set_active_component(Components.TAB)
            self:get_model():notify()
        end
        end

        

        local MenuKeyTable = {
         [keys.Up]    = function(self) self:move_selector(Directions.UP)    end,
         [keys.Down]  = function(self) self:move_selector(Directions.DOWN)  end,
         [keys.Left]  = function(self) self:move_selector(Directions.LEFT)  end,
         [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,

         [keys.Return] = 
             function(self)
--[[
                 print("\n\n\nreturn registered in Tab Controller")
                 assert(MenuItemCallbacks,
                       "MenuItemCallbacks is nil")
                 assert(MenuItemCallbacks[view.parent:get_controller():get_selected_index()],
                       "MenuItemCallbacks[view.parent:get_controller():get_selected_index()] is nil")
                 assert(MenuItemCallbacks[view.parent:get_controller():get_selected_index()][selected],
                       "MenuItemCallbacks[view.parent:get_controller():get_selected_index()][selected] is nil")
                 MenuItemCallbacks[view.parent:get_controller():get_selected_index()][selected](self)
--]]
                 print(selected[1],selected[2])
                 MenuItemCallbacks[selected[1]][selected[2]]()
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
            return selected
        end
        function self:reset_selected_index()
            selected = {1,1}
        end

        function self:move_selector(dir)
            if dir == Directions.UP then
                --move up in acc_index
                if selected[2] - 1 >= 1 then 
                    selected[2] = selected[2] - 1
                --move up by a acc_index
                elseif selected[1] - 1 >= 1 then
                    selected[1] = selected[1] - 1
                    selected[2] = #MenuItemCallbacks[selected[1]]
                end
            elseif dir == Directions.DOWN then
                --move down in acc_index
                if selected[2] + 1 <= #MenuItemCallbacks[selected[1]] then 
                    selected[2] = selected[2] + 1
                --move down by a acc_index
                elseif selected[1] + 1 <= #MenuItemCallbacks then
                    selected[1] = selected[1] + 1
                    selected[2] = 1
                end
            elseif dir == Directions.LEFT then
                self:jump_out()
            end
            self:get_model():notify()
        end
    end)
