SlideshowController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.SLIDE_SHOW)

    -- the default selected indices
    local photo_index = 0
    function self:reset_photo_index() photo_index = 1     end
    function self:set_photo_index(i)  photo_index = i     end
    function self:get_photo_index()   return photo_index  end

    local style_index = 1
    function self:reset_style_index() style_index = 1     end
    function self:set_style_index(i)  style_index = i     end
    function self:get_style_index()   return style_index  end

    local menu_index = 1
    function self:reset_menu_index()  menu_index = 1      end
    function self:set_menu_index(i)   menu_index = i      end
    function self:get_menu_index()    return menu_index   end
    local menu_is_visible = false

    function self:Prep_Slideshow()
        photo_index = 0
--[[
        view.queryText.text = string.gsub(
            adapters[#adapters - model.fp_1D_index + 1][1].required_inputs.query,"%%20"," ")
        view.logo.src  = adapters[#adapters - model.fp_1D_index + 1].logoUrl
--]]
        view.nav_group:add(view.logo)
        view.set_ui[ view.styles[style_index] ]()

        menu_index = 1
        menu_is_visible = false

        for i = 1,5 do
            view:preload_front()
        end
    end

--[=[
    local NavCallbacks =
    {
        --CLOSE THE NAV MENU
        function()
            menu_is_visible = false
            view:nav_out_focus()
        end,
        --GO BACK TO THE FRONT PAGE
        function()
            if view.timer_is_running then
                view.timer:stop()
                view.timer_it_running = false
            end
            if view.off_screen_list[1] ~= nil then
                view.off_screen_list[1]:complete_animation()
            end
            if view.on_screen_list[1] ~= nil then
                view.on_screen_list[1]:complete_animation()
            end
            collectgarbage()

            for i = 1,#view.on_screen_list do
                view.on_screen_list[i]:unparent()
            end
            for i = 1,#view.off_screen_list do
                view.off_screen_list[i]:unparent()
            end
            view.on_screen_list  = {}
            view.off_screen_list = {}
 
            photo_index =  0
            view.prev_i = -1

            menu_is_visible = false
            view:nav_out_focus()

            self:get_model():set_active_component(Components.FRONT_PAGE)
            self:get_model():notify()

        end,
--[[
        --DELETE THIS ALBUM & GO BACK TO THE FRONT PAGE
        function()
        end,
--]]
        --TOGGLE THE SLIDESHOW & CLOSE THE NAV MENU

        function()
            view:toggle_timer()
            menu_is_visible = false
            view:nav_out_focus()
        end,

        --SWITCH SLIDE SHOW STYLE
        function()
            style_index = style_index%(#view.styles) +1
            print(style_index)
            view.set_ui[ view.styles[style_index] ]()
            reset_keys()  
            menu_is_visible = false
            view:nav_out_focus()

        end,

    }
--]=]

    local NavCallbacks =
    {
        --CLOSE THE NAV MENU
        function()
            view.set_ui[ view.styles[1] ]()
            view:pick(1,style_index)
            style_index = 1
            
        end,
        function()
            view.set_ui[ view.styles[2] ]()
            view:pick(2,style_index)
            style_index = 2

        end,
        function()
            menu_index = 1
            --view:toggle_timer()
            menu_is_visible = false
            view:nav_out_focus(style_index)
        end
    }

    local MenuKeyTable = {
        [keys.Up]    = function(self) self:move_selector(Directions.UP) end,
        [keys.Down]  = function(self) self:move_selector(Directions.DOWN) end,
        [keys.Left]  = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
	[keys.BackSpace] = function(self)
            if view.timer_is_running then
                view.timer:stop()
                view.timer_it_running = false
            end
            if view.off_screen_list[1] ~= nil then
                view.off_screen_list[1]:complete_animation()
            end
            if view.on_screen_list[1] ~= nil then
                view.on_screen_list[1]:complete_animation()
            end
            collectgarbage()

            for i = 1,#view.on_screen_list do
                view.on_screen_list[i]:unparent()
            end
            for i = 1,#view.off_screen_list do
                view.off_screen_list[i]:unparent()
            end
            view.on_screen_list  = {}
            view.off_screen_list = {}
 
            photo_index =  0
            view.prev_i = -1
            if menu_is_visible then
        	    menu_is_visible = false
	            view:nav_out_focus(style_index)
            end

            self:get_model():set_active_component(Components.FRONT_PAGE)
            self:get_model():notify()

reset_keys()

	end,
		[keys.p] = function(self)
            view:toggle_timer()
			reset_keys()			
		end,
        [keys.Return] = function(self) 
            if menu_is_visible then
                NavCallbacks[menu_index](style_index)
            else
                menu_is_visible = true
                view:nav_on_focus(style_index)
            end
            
        end
    }


    function self:on_key_down(k)
        if MenuKeyTable[k] then
            MenuKeyTable[k](self)
        else
            reset_keys()
        end
    end

    function self:move_selector(dir)
        print("\n\nKey press when\t\t query index:",
               model.fp_1D_index,"photo index:",photo_index,"on screen:",
               #view.on_screen_list,"off_screen:",#view.off_screen_list,
              "\n")
        photo_index = photo_index + dir[1]
        if photo_index < 0 then
           photo_index = 0
        end
        if menu_is_visible then
            menu_index = menu_index + dir[2]
            if menu_index < 1 or menu_index > #NavCallbacks then
                menu_index = menu_index - dir[2]
            end
            view:nav_move(menu_index)
--[[
            menu_index = menu_index + dir[2]
            if menu_index < 1 or menu_index > #view.nav_items then
                menu_index = menu_index - dir[2]
            end
--]]
        end
--[[
        if #view.on_screen_list > 5 then
            print("removing from on_screen list")
            
            if view.on_screen_list[#view.on_screen_list] ~= nil and
               view.on_screen_list[#view.on_screen_list].parent ~= nil
                                                                 then
                view.on_screen_list[#view.on_screen_list]:unparent()
            end

            view.on_screen_list[#view.on_screen_list]=nil
        end
        if #view.off_screen_list > 5 then
            print("removing from off_screen list")
            if view.off_screen_list[#view.off_screen_list] ~= nil and
               view.off_screen_list[#view.off_screen_list].parent ~= nil
                                                                 then
                view.off_screen_list[#view.off_screen_list]:unparent()
            end
            view.off_screen_list[#view.off_screen_list]=nil
        end
--]]

        --moving foward through the photos
        if dir == Directions.RIGHT then
            view:preload_front()
        --moving back
        elseif dir == Directions.LEFT then
            --toss the end of the off_screen_list
            if photo_index >= 4  then
                view:preload_back()
            end
        end 
        self:get_model():notify()
    end
end)
