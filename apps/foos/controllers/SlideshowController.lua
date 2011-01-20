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

    function self:Prep_Slideshow(i)
        photo_index = i
		view.prev_i = i
        view.background.opacity  = 255
        view.mosaic_background.opacity  = 0

--        view.set_ui[ view.styles[style_index] ]()

        menu_index = 1
        menu_is_visible = false

        for i = 1,5 do
            view:preload_front(true)
        end
		local upper = i
		if i > 4 then
			upper = 4
		end
		for i = 1, upper do
			view:preload_back(true)
		end
		if view.license_on[1] then
			view.license_box:add(view.license_on[1])
		end
    end

    local NavCallbacks =
    {
        --CLOSE THE NAV MENU
        function()
            if style_index ~= 1 and view.set_ui[ view.styles[1] ]() then
    	        view:pick(1,style_index)
	            style_index = 1
				mediaplayer:play_sound("audio/Fo'os Flip Slideshow Sound.mp3")
			else reset_keys()
            end
        end,
        function()
            if style_index ~= 2 and view.set_ui[ view.styles[2] ]() then
    	        view:pick(2,style_index)
	            style_index = 2
				mediaplayer:play_sound("audio/Fo'os Flip Slideshow Sound.mp3")
			else reset_keys()
			end
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
			view.license_off     = {}
			for i = 1, #view.license_on do
				if view.license_on[i].parent ~= nil then
					view.license_on[i]:unparent()
				end
			end
			view.license_on      = {}
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
  --      print("\n\nKey press when\t\t query index:",
  --             model.fp_1D_index,"photo index:",photo_index,"on screen:",
  --             #view.on_screen_list,"off_screen:",#view.off_screen_list,
  --            "\n")
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
        end

        --moving foward through the photos
        if dir == Directions.RIGHT then
            if view:preload_front(true) == false then
				photo_index = photo_index - dir[1]
			end
		if view.timer_is_running then
			view.timer:stop()
			view.timer:start()
		end
        --moving back
        elseif dir == Directions.LEFT then
            --toss the end of the off_screen_list
            if photo_index >= 4  then
                if view:preload_back(true) == false then
					photo_index = photo_index - dir[1]
				end
            end
		if view.timer_is_running then
			view.timer:stop()
			view.timer:start()
		end
        end 
        self:get_model():notify()
    end
end)
