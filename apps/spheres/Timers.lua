

--Countdown Numbers

local countdown_numbers = {}

for i = 1,3 do
    
    local t = Text{
        text = i,
        font = "DejaVu Sans Mono 200px"
    }
    
    local c = Canvas(t.w,t.h)
    
    c:text_element_path(t)
    
    c:set_source_color("ffffff")
    
    c:stroke(true)
    
    countdown_numbers[i] = c:Image()
    
    clone_sources_layer:add( countdown_numbers[i] )
    
end


--The animated countdown number
local countdown_clone = Clone{position = {screen_w/2,screen_h/2}}

hud_layer:add(countdown_clone)


--The scale/opacity countdown animation
local source_i, src, countdown_callback, countdown_done

countdown_done = function(s)
    
    source_i = source_i - 1
    
    src = countdown_numbers[  source_i  ]
    
    if src then
        
        countdown_clone:set{
            source       = src,
            anchor_point = {  src.w/2,  src.h/2  },
            scale        = {  3,  3  },
            opacity      = 255,
        }
        
        add_step_func(
            
            1000,
            
            function(p)
                
                countdown_clone.scale   =   2*(1-p)+1
                
                countdown_clone.opacity = 255*(1-p)
                
            end,
            
            countdown_done
            
        )
        
    elseif countdown_callback then
        
        countdown_callback()
        
    end
    
end



--[[
function countdown_animation(callback)
    
    source_i = #countdown_numbers + 1
    
    countdown_callback = callback
    
    countdown_done()
    
end
--]]

STATE:add_state_change_function(nil,"COUNTDOWN",
    
    function()
        
        source_i = #countdown_numbers + 1
        
        countdown_callback = function() STATE:change_state_to("GAME") end
        
        countdown_done()
        
    end
)



---[[
--Timer Numbers

local timer_numbers = {}

for i = 0,9 do
    
    local t = Text{
        text = i,
        font = "DejaVu Sans Mono 100px"
    }
    
    local c = Canvas(t.w,t.h)
    
    c:text_element_path(t)
    
    c:set_source_color("ffffff")
    
    c:stroke(true)
    
    c:set_source_color("ff0000")
    
    c:fill(true)
    
    timer_numbers[i] = c:Image()
    
    clone_sources_layer:add( timer_numbers[i] )
    
end
--]]

local digits = {}

function start_timer(start_value,callback)
    
    local num_digits = 0
    
    while(start_value / 10 > 1) do
        
        start_value = start_value / 10
        
        num_digits = num_digits + 1
        
    end
    
end


