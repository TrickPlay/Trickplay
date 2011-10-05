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
    
    local dx = dist*math.sin(math.pi/180*angle)
    local dy = dist*math.cos(math.pi/180*angle)
    
    Animation_Loop:add_animation{
        duration = dur,
        on_step  = function(s,p)
            
            h.x = start_x + dx*p + 5*math.sin(math.pi*4*p)
            h.y = start_y - dy*p
            
            if p > 3/4 then
                
                h.opacity = 255 * ( 1  -  (p-.75)*4 )
                
            end
        end,
        on_completed = function()
            h:unparent()
            h = nil
        end
    }
    
    local scale = math.random(30,50)/10
    print(s)
    Animation_Loop:add_animation{
        duration = dur/3,
        on_step  = function(s,p)
            
            h.scale = {p/scale,p/scale}
        end,
    }
    clone_counter[h] = "heart"
    layers.background:add(h)
    
end


function fx:heart_barrage(start_x,start_y, num)
    
    for i = 1,num do
        
        Animation_Loop:add_animation{
            
            duration = i/4 - .2,
            
            on_step = function() end,
            
            on_completed = function()
                
                fx:launch_heart(
                    start_x,
                    start_y,
                    1.5,
                    math.random(-20,20),
                    200
                )
                
            end,
            
        }
        
    end
    
end

return fx