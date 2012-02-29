
--------------------------------------------------------------------------------
--Countdown Numbers
--------------------------------------------------------------------------------
local countdown_numbers = {}

--make the canvas numbers
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


--------------------------------------------------------------------------------
-- The scale/opacity countdown animation

local source_i, src, countdown_callback, countdown_done

-- this function calls it self as the on_completed call_back for the
-- 'scale/opacity countdown' animation, it stops when the number reaches 0
countdown_done = function(s)
    
    
    
    if source_i > 0 then
        
        src = countdown_numbers[  source_i  ]
        
        --change the clone to the new number
        countdown_clone:set{
            source       = src,
            anchor_point = {  src.w/2,  src.h/2  },
            scale        = {  3,  3  },
            opacity      = 255,
        }
        
        --animate it
        add_step_func(
            
            1000,
            
            function(p)
                
                countdown_clone.scale   =   2*(1-p)+1
                
                countdown_clone.opacity = 255*(1-p)
                
            end,
            
            countdown_done -- recursive
            
        )
        
        source_i = source_i - 1 -- decrement for the next iteration
        
    --if the end of the countdown, don't continue
    elseif countdown_callback then
        
        countdown_callback()
        
    end
    
end

--------------------------------------------------------------------------------
-- start the countdown

STATE:add_state_change_function(nil,"COUNTDOWN",
    
    function()
        
        source_i = #countdown_numbers
        
        countdown_callback = function() STATE:change_state_to("GAME") end
        
        countdown_done()
        
    end
)

--TODO: need a better solution than just blindly initiating the countdown 2 seconds after the round ended
STATE:add_state_change_function(nil,"ROUND_OVER",
    
    function()
        
        dolater(2000,function() STATE:change_state_to("COUNTDOWN") end)
        
    end
)



