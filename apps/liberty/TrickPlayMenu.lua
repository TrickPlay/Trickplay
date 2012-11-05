
local spacing = 130

local function create()
    
    local instance = Group{name="trick play menu"}
    
    local focus = {
        Clone{source=hidden_assets_group:find_child("tp-bold-stop"), },
        Clone{source=hidden_assets_group:find_child("tp-bold-beg"),  },
        Clone{source=hidden_assets_group:find_child("tp-bold-rew"),  },
        Clone{source=hidden_assets_group:find_child("tp-bold-pause"),},
        Clone{source=hidden_assets_group:find_child("tp-bold-ff"),   },
        Clone{source=hidden_assets_group:find_child("tp-bold-end"),  },
    }
    local nonfocus = {
        Clone{source=hidden_assets_group:find_child("tp-thin-stop"), },
        Clone{source=hidden_assets_group:find_child("tp-thin-beg"),  },
        Clone{source=hidden_assets_group:find_child("tp-thin-rew"),  },
        Clone{source=hidden_assets_group:find_child("tp-thin-pause"),},
        Clone{source=hidden_assets_group:find_child("tp-thin-ff"),   },
        Clone{source=hidden_assets_group:find_child("tp-thin-end"),  },
    }
    
    local icon = Clone{source = channel_icon,y=-20}
    
    --------------------------------------------------------------------
    
    instance:add(unpack(nonfocus))
    instance:add(unpack(   focus))
    
    
    instance:foreach_child(function(c)
        c.anchor_point = {c.w/2,c.h/2}
        c.scale = 1080/720
        c.y = 40
    end)
    instance:add( icon )
    
    for i = 1,#focus do
        
        focus[i].x    = spacing*(i - #focus/2 - .5)
        nonfocus[i].x = spacing*(i - #focus/2 - .5)
        
        focus[i].opacity = 0
        
    end
    
    --nonfocus[4].x = nonfocus[4].x - .5
    
    --------------------------------------------------------------------
    
    local index = 1
    
    local animating_menu = false
    local animating = false
    local key_presses = {
        [keys.Right] = function()
            if animating or index == #focus then return end
            focus[index]:animate{duration=290,opacity = 0}
            index = index + 1
            focus[index]:animate{duration = 200,opacity=255,on_completed = function() animating = false end}
        end,
        [keys.Left]  = function()
            if animating or index == 1 then return end
            animating = true
            focus[index]:animate{duration=290,opacity = 0}
            index = index - 1
            focus[index]:animate{duration = 200,opacity=255,on_completed = function() animating = false end}
        end,
        [keys.BACK] = function()
            if animating then return end
            animating = true
            
            instance:animate{
                duration = 300,
                z = -300,
                opacity = 0,
                on_completed = function() 
                    instance:unparent() 
                    animating = false 
                end
            }
            currently_playing_content:grab_key_focus()
            backdrop:set_horizon(700)
            backdrop:set_bulb_x(screen_w/2)
        end,
    }
    
    function instance:on_key_down(k,...)
        return key_presses[k] and key_presses[k]() or focus[index].source.on_key_down and focus[index].source:on_key_down(k,...)
    end
    
    function instance:on_key_focus_in(self)
        icon.anchor_point = {icon.w/2,icon.h}
        focus[index]:animate{duration = 200,opacity=255}
    end
    function instance:on_key_focus_out(self)
        focus[index]:animate{duration=290,opacity = 0}
        index = 1
    end
    
    
    local cursor = make_cursor(183+168+153+140+124)
    
    instance:add(cursor)
    
    return instance
    
end


return create()
