
return function(p)
    
    local prev_menu = p.prev_menu
    local upper     = p.upper
    local lower     = p.lower
    local upper_y   = p.upper_y or  300
    local lower_y   = p.lower_y or  825
    local upper_z   = p.upper_z or p.type == "flat" and 0 or -300
    local lower_z   = p.lower_z or    0
    
    local instance = Group()
    
    instance:add(upper,lower)
    
    
    upper.y = upper_y
    upper.z = upper_z
    lower.y = lower_y
    lower.z = lower_z
    
    local y_mode = "EASE_OUT_QUAD"
    local z_mode = "EASE_IN_QUAD"
    local dosado_1 = p.type == "flat" and Timeline{
        duration = 400,
        on_new_frame = function(tl,ms,p)
            upper.z = -50*math.sin(math.pi*p)
            lower.z =  50*math.sin(math.pi*p)
            upper.y = upper_y + (lower_y - upper_y)*p
            lower.y = lower_y - (lower_y - upper_y)*p
        end,
    } or Animator{
        duration = 600,
        properties = {
            {
                source = upper, name = "y",
                keys = {
                    {0.0,y_mode,upper_y},
                    --{0.4,"LINEAR",lower_y+(lower_y-upper_y)*2/3},
                    --{0.6,"LINEAR",lower_y},
                    {1.0,y_mode,lower_y},
                }
            },
            {
                source = upper, name = "z",
                keys = {
                    {0.0,z_mode,upper_z},
                    --{0.4,"LINEAR",upper_z},
                    {1.0,z_mode,lower_z},
                }
            },
            {
                source = upper, name = "opacity",
                keys = {
                    {0.0,"EASE_OUT_QUAD",255},
                    {0.5,"EASE_OUT_QUAD",255*.7},
                    {1.0,"EASE_IN_QUAD",255},
                }
            },
            {
                source = lower, name = "y",
                keys = {
                    {0.0,y_mode,lower_y},
                    --{0.4,"LINEAR",lower_y+(lower_y-upper_y)*1/3},
                    --{0.6,"LINEAR",upper_y},
                    {1.0,y_mode,upper_y},
                }
            },
            {
                source = lower, name = "z",
                keys = {
                    {0.0,z_mode,lower_z},
                    --{0.4,"LINEAR",lower_z},
                    {1.0,z_mode,upper_z},
                }
            },
            {
                source = lower, name = "opacity",
                keys = {
                    {0.0,"EASE_OUT_QUAD",255},
                    {0.5,"EASE_OUT_QUAD",255*.7},
                    {1.0,"EASE_IN_QUAD",255},
                }
            },
        }
    }
    
    if p.type == "flat" then
        dosado_1.on_completed = function()
            upper:raise_to_top()
            upper.z = lower_z
            upper:grab_key_focus()
        end
    else
        dosado_1.timeline.on_completed = function()
            upper:raise_to_top()
            upper.z = lower_z
            upper:grab_key_focus()
        end
    end
    
    local dosado_2 =  p.type == "flat" and Timeline{
        duration = 400,
        on_new_frame = function(tl,ms,p)
            lower.z = -50*math.sin(math.pi*p)
            upper.z =  50*math.sin(math.pi*p)
            lower.y = upper_y + (lower_y - upper_y)*p
            upper.y = lower_y - (lower_y - upper_y)*p
        end,
    } or Animator{
        duration = 600,
        properties = {
            {
                source = lower, name = "y",
                keys = {
                    {0.0,y_mode,upper_y},
                    --{0.6,"LINEAR",lower_y},
                    {1.0,y_mode,lower_y},
                }
            },
            {
                source = lower, name = "z",
                keys = {
                    {0.0,z_mode,upper_z},
                    --{0.4,"LINEAR",upper_z},
                    {1.0,z_mode,lower_z},
                }
            },
            {
                source = lower, name = "opacity",
                keys = {
                    {0.0,"EASE_OUT_QUAD",255},
                    {0.5,"EASE_OUT_QUAD",255*.7},
                    {1.0,"EASE_IN_QUAD",255},
                }
            },
            {
                source = upper, name = "y",
                keys = {
                    {0.0,y_mode,lower_y},
                    --{0.6,"LINEAR",upper_y},
                    {1.0,y_mode,upper_y},
                }
            },
            {
                source = upper, name = "z",
                keys = {
                    {0.0,z_mode,lower_z},
                    --{0.4,"LINEAR",lower_z},
                    {1.0,z_mode,upper_z},
                }
            },
            {
                source = upper, name = "opacity",
                keys = {
                    {0.0,"EASE_OUT_QUAD",255},
                    {0.5,"EASE_OUT_QUAD",255*.7},
                    {1.0,"EASE_IN_QUAD",255},
                }
            },
        }
    }
    
    if p.type == "flat" then
        dosado_2.on_completed = function()
            lower:raise_to_top()
            lower.z = lower_z
            lower:grab_key_focus()
        end
    else
        dosado_2.timeline.on_completed = function()
            lower:raise_to_top()
            lower.z = lower_z
            lower:grab_key_focus()
        end
    end
    
    local cursor = make_cursor(p.type == "flat" and (200*1.1) or(183+168+153+140+124))
    cursor.x = screen_w/2
    cursor.y = lower_y-42
    instance:add(cursor)
    
    local animating_back_to_prev_menu = false
    local switched = false
    local keypresses = {
        [keys.Up] = function()
            if  instance.is_animating or 
                dosado_1.timeline and 
                dosado_1.timeline.is_playing or 
                dosado_1.is_playing or 
                dosado_2.timeline and 
                dosado_2.timeline.is_playing or 
                dosado_2.is_playing then
                return
            end
            print(upper.icon_w,lower.icon_w)
            if not switched then
                dosado_1:start()
                if upper.icon_w then
                    cursor:change_w(upper.icon_w)
                end
            else
                dosado_2:start()
                if lower.icon_w then
                    cursor:change_w(lower.icon_w)
                end
            end
            switched = not switched
            instance:grab_key_focus()
        end,
        [keys.Down] = function()
            if  instance.is_animating or 
                dosado_1.timeline and 
                dosado_1.timeline.is_playing or 
                dosado_1.is_playing or 
                dosado_2.timeline and 
                dosado_2.timeline.is_playing or 
                dosado_2.is_playing then
                return
            end
            print(upper.icon_w,lower.icon_w)
            if not switched then
                dosado_1:start()
                if upper.icon_w then
                    cursor:change_w(upper.icon_w)
                end
            else
                dosado_2:start()
                if lower.icon_w then
                    cursor:change_w(lower.icon_w)
                end
            end
            switched = not switched
            instance:grab_key_focus()
        end,
        [keys.BACK] = function()
            if  prev_menu.is_animating or 
                instance.is_animating or 
                animating_back_to_prev_menu or 
                dosado_1.timeline and 
                dosado_1.timeline.is_playing or 
                dosado_1.is_playing or 
                dosado_2.timeline and 
                dosado_2.timeline.is_playing or 
                dosado_2.is_playing then 
                return 
            end
            animating_back_to_prev_menu = true
            instance:animate{
                duration = 300,
                z = -300,
                opacity = 0,
                on_completed = function() 
                    instance:unparent() 
                    animating_back_to_prev_menu = false 
                end
            }
            prev_menu:grab_key_focus()
            prev_menu:animate{
                duration = 300,
                z = 0,
                opacity = 255,
            }
            if prev_menu == main_menu then
                backdrop:set_horizon(700)
            end
            
        end,
        [keys.VOL_UP]   = raise_volume,
        [keys.VOL_DOWN] = lower_volume,
    }
    
    function instance:on_key_down(k)
    
        return keypresses[k] and keypresses[k]()
    end
    function instance:on_key_focus_in(self)
        instance:animate{
            duration = 300,
            z = 0,
            opacity = 255,
        }
        if not switched then
            lower:grab_key_focus()--on_key_focus_in()
        else
            upper:grab_key_focus()--on_key_focus_in()
        end
    end
    instance.opacity = 0
    return instance
end