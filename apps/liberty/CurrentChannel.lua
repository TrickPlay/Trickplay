

local create = function()
    local instance = Group()
    local left_margin  = 400
    local right_margin = 1425
    --------------------------------------------------------------------
    local slider = Group{name="slider",y = 800}
    
    local txt__on_now = make_bolding_text{
        text = "ON NOW",
        color="white",
        sz=90,
        duration = 200
    }
    txt__on_now.x =left_margin
    txt__on_now.expand:on_completed()
    local txt__next = make_bolding_text{
        text = "NEXT",
        color="white",
        sz=90,
        duration = 200
    }
    txt__next.x =right_margin
    slider:add(txt__on_now,txt__next)
    instance:add(slider)
    --------------------------------------------------------------------
    local channel_logo = Clone()
    --------------------------------------------------------------------
    local curr_show_time = Text{
        text = "12:30 - 13:15",
        font = "InterstateProRegular 25px",
        y = 141,
        x = left_margin,
        color="white",
    }
    local curr_show = Text{
        text = "Death in Paradise",
        font = "InterstateProRegular 38px",
        y = 209,
        x = left_margin,
        color="white",
    }
    slider:add(channel_logo,curr_show_time,curr_show)
    --------------------------------------------------------------------
    local cursor = make_cursor(500)
    cursor.x = left_margin + 250
    cursor.y = slider.y - 42
    instance:add(cursor)
    --------------------------------------------------------------------
    local keypresses = {
        [keys.Left] = function()
            if slider.is_animating then return end
            slider:animate{
                duration = 300,
                x = 0,
            }
            txt__on_now.expand:start()
            txt__next.contract:start()
        end,
        [keys.Right] = function()
            if slider.is_animating then return end
            slider:animate{
                duration = 300,
                x = left_margin - right_margin,
            }
            txt__on_now.contract:start()
            txt__next.expand:start()
        end,
        [keys.BACK] = function()
            if main_menu.is_animating or instance.is_animating then return end
            instance:animate{
                duration = 300,
                z = -300,
                opacity = 0,
            }
            main_menu:grab_key_focus()
            main_menu:animate{
                duration = 300,
                z = 0,
                opacity = 255,
            }
            backdrop:set_horizon(700)
            
        end,
    }
    
    function instance:on_key_down(k)
    
        return keypresses[k] and keypresses[k]()
    end
    --------------------------------------------------------------------
    function instance:on_key_focus_in(self)
        instance:animate{
            duration = 300,
            z = 0,
            opacity = 255,
        }
    end
    instance.opacity = 0
    instance.z = -300
    --------------------------------------------------------------------
    return instance
end

return create