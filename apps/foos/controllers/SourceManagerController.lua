SourceManagerController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.SOURCE_MANAGER)

    --indexing for source selection
    local src_selected = 1
    function self:reset_src_selected_index()
        src_selected = 1
    end
    function self:set_src_selected_index(i)
        src_selected = i
    end
    function self:get_src_selected_index()
        return src_selected
    end

    --indexing for selection within a source's accordian menu
    local acc_selected = {1,1}
    function self:reset_acc_selected_index()
        acc_selected = {1,1}
    end
    function self:set_acc_selected_index(r,c)
        acc_selected = {r,c}
    end
    function self:get_acc_selected_index()
        return acc_selected[1],acc_selected[2]
    end

    local in_box = false
    local query_text = ""
    local login_text = {"",""}
    local controller = self

    local TextObj = function(obj)
       local text_obj = obj
       --local default_text = text_obj.text
       text_obj.editable = true
       text_obj:grab_key_focus()
       in_box = true
       function text_obj:on_key_down(k)
           if keys.Return == k then
               self.on_key_down = nil
               screen:grab_key_focus()
               --controller:on_key_down(k)
               in_box = false
               return true
           end
       end
       function text_obj:on_key_focus_out()
           print("\n\n on key focus out")
           self.editable = false
           self.on_key_focus_out = nil
           acc_selected[1] = acc_selected[1] + 1

           query_text = self.text
           login_text[1] = self.text
           model:notify()
       end

    end

    local MenuItemCallBacks =
    {
        ["QUERY"] = 
        {
            --Text Box
            {function()
                TextObj( view.accordian_text["QUERY"][1] )
            end},
            --save
            {function() 
                if query_text ~= "" then
                    table.insert(adapters, dofile("adapter/"..
                                 adapterTypes[src_selected].."/adapter.lua"))
                    adaptersTable[#adapters] = adapterTypes[src_selected]
                    local search = string.gsub(query_text," ","%%20")
                    adapters[#adapters][1].required_inputs.query = search
                    searches[#adapters] = search
                    Add_Cover()


--[[
                    model.album_group:clear()
                    model.albums = {}
                    Setup_Album_Covers()
                    model:notify()
--]]
                    query_text = ""
                end
                view.accordian = false
                view:leave_accordian()
            end,
            --cancel
            function() 
                query_text = ""
                view.accordian = false
                view:leave_accordian()
            end}
        },
        ["LOGIN"] = 
        {
            {function()
                TextObj( view.accordian_text["LOGIN"][1] ) end},
            {function()
                TextObj( view.accordian_text["LOGIN"][2] ) end},
            {function()
print("LOGIN OK")
            	 if login_text[1] ~= "" then
                    table.insert(adapters, dofile("adapter/"..
                                 adapterTypes[src_selected]..
                                 "/adapter.lua"))

                    adaptersTable[#adapters] = adapterTypes[src_selected]
                    local search = string.gsub(query_text," ","%%20")
                    adapters[#adapters]:getUserID(search)
                    adapters[#adapters][1].required_inputs.query = search                    
                    searches[#adapters] = search
                    Add_Cover()

                    login_text[1] = ""
                end
                view.accordian = false
                view:leave_accordian()
            end,
            function()
                view.accordian = false
                view:leave_accordian()
            end}
        }
    }


    local MenuKeyTable = {
        [keys.Up]     = function(self) self:move_selector(Directions.UP   ) end,
        [keys.Down]   = function(self) self:move_selector(Directions.DOWN ) end,
        [keys.Left]   = function(self) self:move_selector(Directions.LEFT ) end,
        [keys.Right]  = function(self) self:move_selector(Directions.RIGHT) end,
        [keys.Return] = function(self) 
            if view.accordian == false then
                --enter the accordian
                view.accordian = true
                view.enter_accordian()
            end
            MenuItemCallBacks[model.source_list[src_selected][2]][
                             acc_selected[1] ][acc_selected[2] ]()
            self:get_model():notify()
       end
    }


    function self:on_key_down(k)
        if MenuKeyTable[k]  and not in_box then
            MenuKeyTable[k](self)
        else
            reset_keys()           
        end
    end


    function self:move_selector(dir)
        reset_keys()            

        if view.accordian == true then
            local next_spot= {acc_selected[1]+dir[2],
                              acc_selected[2]+dir[1]}
--[[
            if next_spot > 0 and next_spot <= 
              #view.accordian_items[  model.source_list[src_selected][2]  ] then
--]]
            if view.accordian_items[  model.source_list[src_selected][2]  ][next_spot[1] ] ~= nil 
            and view.accordian_items[  model.source_list[src_selected][2]  ][next_spot[1] ][ next_spot[2] ] ~= nil then
                acc_selected = {next_spot[1],next_spot[2]}
            end
            if next_spot[1] == #view.accordian_items[  model.source_list[src_selected][2]  ] - 1 and
               next_spot[2] == 2 then
               acc_selected = {#view.accordian_items[  model.source_list[src_selected][2]  ] - 1, 1}
            end

        else
            local next_spot= src_selected+dir[2]
            if next_spot > 0 and 
               next_spot <= #view.menu_items then
                src_selected = next_spot
            end
            if dir == Directions.LEFT then
                 self:get_model():set_active_component(Components.FRONT_PAGE)
            end
        end
        self:get_model():notify()

    end
end)
