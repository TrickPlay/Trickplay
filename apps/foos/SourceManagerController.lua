SourceManagerController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.SOURCE_MANAGER)

    -- the default selected index
    local src_selected = 1
    local acc_selected = 1

    local controller = self

    local TextObj = function(obj)
                local text_obj = obj
                local default_text = text_obj.text
                text_obj.editable = true
                text_obj:grab_key_focus()
                function text_obj:on_key_down(k)
                    if keys.Return == k then
print("TextObj recorded a RETURN press")
                        self.on_key_down = nil
                        screen:grab_key_focus()
                        --controller:on_key_down(k)
                        return true
                    end
                end
                function text_obj:on_key_focus_out()
                    print("\n\n on key focus out")
                    self.editable = false
                    self.on_key_focus_out = nil

                    if self.text ~= ""  then
								adapters[1][1].required_inputs.query = self.text
								searches[1] = self.text
                    end

                    self.text = default_text               
                end

    end

    local MenuItemCallBacks =
    {
        ["QUERY"] = 
        {
            --Text Box
            function()
                TextObj( view.accordian_text["QUERY"][1] )
            end,
            --save
            function() 
                view.accordian = false
                view:leave_accordian()
            end,
            --cancel
            function() 
                view.accordian = false
                view:leave_accordian()
            end
        },
        ["LOGIN"] = 
        {
            function()
                TextObj( view.accordian_text["LOGIN"][1] ) end,
            function()
                TextObj( view.accordian_text["LOGIN"][2] ) end,
            function()
                view.accordian = false
                view:leave_accordian()
            end,
            function()
                view.accordian = false
                view:leave_accordian()
            end
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
            else
                MenuItemCallBacks[model.source_list[src_selected][2]][acc_selected]()
					
            end
            self:get_model():notify()
            
        end
    }


    function self:on_key_down(k)
        print("sdl;fjsd;afj;skdafj;skajd\n\n\n")
        if MenuKeyTable[k] then
            MenuKeyTable[k](self)
        end
    end

    function self:reset_src_selected_index()
        src_selected = 1
    end

    function self:set_src_selected_index(i)
        src_selected = i
    end

    function self:get_src_selected_index()
        return src_selected
    end



    function self:reset_acc_selected_index()
        acc_selected = 1
    end

    function self:set_acc_selected_index(i)
        acc_selected = i
    end

    function self:get_acc_selected_index()
        return acc_selected
    end



    function self:move_selector(dir)
        local next_spot 
        if view.accordian == true then
            next_spot= acc_selected+dir[1]
            if next_spot > 0 and next_spot <= 
              #view.accordian_items[  model.source_list[src_selected][2]  ] then
                acc_selected = next_spot
            end
        else
            next_spot= src_selected+dir[2]
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
