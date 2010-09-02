SlideshowController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.SLIDE_SHOW)

    -- the default selected indices
    local photo_index = 1
    function self:reset_photo_index() photo_index = 1     end
    function self:set_photo_index(i)  photo_index = i     end
    function self:get_photo_index()   return photo_index  end

    local style_index = 1
    function self:reset_style_index() style_index = 1     end
    function self:set_style_index(i)  style_index = i     end
    function self:get_style_index()   return style_index  end
function self:Prep_Slideshow()

    view.queryText.text = string.gsub(
                adapters[model.fp_1D_index][1].required_inputs.query,"%%20"," ")
    view.logo = Image 
    { 
        src  = adapters[model.fp_1D_index].logoUrl,
        x    = 20,
        y    = 130,
        size = {300,225}
    }
    view.ui:add(view.logo)
    for i = 1,5 do
        view:preload_front()
    end
end

    local MenuKeyTable = {
        [keys.Up]    = function(self) view:toggle_timer() end,
        [keys.Down]  = function(self) view:toggle_fullscreen() end,
        [keys.Left]  = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
        [keys.Return] = function(self) 
--            Setup_Album_Covers()
            --model.curr_slideshow:stop()
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

            view.on_screen_list  = {}
            view.off_screen_list = {}
 
            photo_index = 1
            view.prev_i = 0
            view.ui:clear()
            view.ui:add( overlay_image, background, background2, caption,
                         view.queryText, controls )


            self:get_model():set_active_component(Components.FRONT_PAGE)
            self:get_model():notify()
        end
    }


    function self:on_key_down(k)
            reset_keys()            
        if MenuKeyTable[k] then
            MenuKeyTable[k](self)
        end
    end

    function self:move_selector(dir)
        photo_index = photo_index + dir[1]
        if photo_index <= 0 then
           photo_index = 1
        end
        --moving foward through the photos
        if dir == Directions.RIGHT then
           view:preload_front()
           if #view.on_screen_list > 5 then
               print("removing from on_screen list")
               
               if view.on_screen_list[#view.on_screen_list] ~= nil and
                  view.on_screen_list[#view.on_screen_list].parent ~= nil
                                                                    then
                   view.on_screen_list[#view.on_screen_list]:unparent()
               end

               view.on_screen_list[#view.on_screen_list]=nil
           end
        --moving back
        elseif dir == Directions.LEFT then
           --toss the end of the off_screen_list
           if #view.off_screen_list > 5 then
               print("removing from off_screen list")
               if view.off_screen_list[#view.off_screen_list] ~= nil and
                  view.off_screen_list[#view.off_screen_list].parent ~= nil
                                                                    then
                   view.off_screen_list[#view.off_screen_list]:unparent()
               end
               view.off_screen_list[#view.off_screen_list]=nil
           end
           if photo_index - #view.on_screen_list+1 >1 then
               view:preload_back()
           end
        end 
        self:get_model():notify()
    end
end)
