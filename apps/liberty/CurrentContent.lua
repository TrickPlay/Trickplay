
local instance = Clone()

local animating = false 

local launch_trickplay_menu = function()
    if animating then return end
    animating = true
    
    menu_layer:add(trick_play_menu)
    trick_play_menu:lower_to_bottom()
    trick_play_menu.z = -300
    trick_play_menu.opacity = 0
    
    dolater(function()
    trick_play_menu:animate{
        duration = 300,
        z        = 0,
        opacity  = 255,
        on_completed = function() 
            animating = false 
        end
    }
    trick_play_menu:grab_key_focus()
    end)
end
local launch_channel_menu = function()
    if animating or not channel_menu.is_ready then return end
    animating = true
    
    menu_layer:add(channel_menu)
    channel_menu:lower_to_bottom()
    channel_menu.z = -300
    channel_menu.opacity = 0
    
    dolater(function()
    channel_menu:animate{
        duration = 300,
        z        = 0,
        opacity  = 0,
        on_completed = function() 
            animating = false 
        end
    }
    channel_menu:grab_key_focus()
    backdrop:set_horizon(500)
    backdrop:set_bulb_x(200)
    backdrop:anim_x_rot(65) -- 70)
    end)
end

local launch_main_menu = function()
    if animating then return end
    animating = true
    
    main_menu:animate{
        duration = 300,
        z        = 0,
        opacity  = 255,
        on_completed = function() 
            instance:unparent() 
            animating = false 
        end
    }
    main_menu:grab_key_focus()
end

local key_presses = {
    [keys.Up]    = launch_channel_menu,
    [keys.Down]  = launch_channel_menu,
    [keys.Left]  = launch_trickplay_menu,
    [keys.Right] = launch_trickplay_menu,
    [keys.MENU]  = launch_main_menu,
    [keys.BACK]  = launch_main_menu,
    [keys.VOL_UP]   = raise_volume,
    [keys.VOL_DOWN] = lower_volume,
}

function instance:on_key_down(k,...)
    return key_presses[k] and key_presses[k]()
end

function instance:on_key_focus_in()
    backdrop:animate{
        duration = 300,
        opacity  = 0,
    }
end
function instance:on_key_focus_out()
    backdrop:animate{
        duration = 300,
        opacity  = 255,
    }
end
return instance