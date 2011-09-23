local fx = {}

local heart_src

function fx:init()
    
    heart_src = Image{src = "assets/lvl2/heart.png"}
    
    layers.srcs:add(heart_src)
end

function fx:launch_heart(start_x,start_y,dur,angle, dist)
    
    local h = Clone{
        source = heart_src,
        scale  = {0,0},
        x      = start_x,
        y      = start_y,
    }
    
    local dx = dist*math.cos(math.pi/180*angle)
    local dy = dist*math.sin(math.pi/180*angle)
    
    Animation_Loop:add_animation{
        duration = dur,
        on_step  = function(s,p)
            
            h.x = start_x + dx*p
            h.y = start_y - dy*p + 10*math.sin(math.pi*2*p)
            
            if p > 3/4 then
                
                h.opacity = 255 * ( 1  -  (p-.75)*4 )
                
            end
        end,
        on_completed = function()
            h:unparent()
            h = nil
        end
    }
    
    Animation_Loop:add_animation{
        duration = dur/3,
        on_step  = function(s,p)
            
            h.scale = {.25*p,.25*p}
        end,
    }
    
end


function fx:heart_barrage(start_x,start_y, num)
    
    for i = 1,num do
        
        Animation_Loop:add_animation{
            
            duration = i/20,
            
            on_step = function() end,
            
            on_completed = function()
                
                fx:launch_heart(
                    start_x,
                    start_y,
                    1,
                    math.random(-20,20),
                    dist
                )
                
            end,
            
        }
        
    end
    
end

return fx